#
# Cookbook:: openstack-telemetry
# Recipe:: gnocchi_configure
#
# Copyright:: 2019-2021, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class ::Chef::Recipe
  include ::Openstack
  include Apache2::Cookbook::Helpers
end

include_recipe 'openstack-telemetry::common'

platform = node['openstack']['telemetry']['platform']
db_user = node['openstack']['db']['telemetry_metric']['username']
db_pass = get_password 'db', 'gnocchi'
bind_service = node['openstack']['bind_service']['all']['telemetry_metric']
bind_service_address = bind_address bind_service

# define secrets that are needed in the gnocchi.conf
node.default['openstack']['telemetry_metric']['conf_secrets'].tap do |conf_secrets|
  conf_secrets['database']['connection'] =
    db_uri('telemetry_metric', db_user, db_pass)
  conf_secrets['indexer']['url'] =
    db_uri('telemetry_metric', db_user, db_pass)
  conf_secrets['keystone_authtoken']['password'] =
    get_password 'service', 'openstack-telemetry_metric'
end

identity_endpoint = public_endpoint 'identity'
auth_url = identity_endpoint.to_s

node.default['openstack']['telemetry_metric']['conf'].tap do |conf|
  conf['api']['host'] = bind_service_address
  conf['api']['port'] = bind_service['port']
  conf['keystone_authtoken']['auth_url'] = auth_url
end

# merge all config options and secrets to be used in the gnocchi.conf
gnocchi_conf_options = merge_config_options 'telemetry_metric'
template node['openstack']['telemetry_metric']['conf_file'] do
  source 'openstack-service.conf.erb'
  cookbook 'openstack-common'
  owner node['openstack']['telemetry_metric']['user']
  group node['openstack']['telemetry_metric']['group']
  mode '640'
  sensitive true
  variables(
    service_config: gnocchi_conf_options
  )
  notifies :restart, 'service[apache2]'
end

# drop gnocchi_resources.yaml to ceilometer folder (current workaround since not
# included in ubuntu package)
cookbook_file File.join(node['openstack']['telemetry']['conf_dir'], 'gnocchi_resources.yaml') do
  source 'gnocchi_resources.yaml'
  owner node['openstack']['telemetry']['user']
  group node['openstack']['telemetry']['group']
  mode '640'
  only_if { platform?('ubuntu') }
end

# drop api-paste.ini to gnocchi folder (default ini will not use keystone auth)
cookbook_file File.join(node['openstack']['telemetry_metric']['conf_dir'], 'api-paste.ini') do
  source 'api-paste.ini'
  owner node['openstack']['telemetry_metric']['user']
  group node['openstack']['telemetry_metric']['group']
  mode '640'
end

# drop event_pipeline.yaml to ceilometer folder (gnocchi does not use events and
# the default event_pipeline.yaml will lead to a queue "event.sample" in rabbit
# without a consumer)
cookbook_file File.join(node['openstack']['telemetry']['conf_dir'], 'event_pipeline.yaml') do
  source 'event_pipeline.yaml'
  owner node['openstack']['telemetry']['user']
  group node['openstack']['telemetry']['group']
  mode '640'
end

if node['openstack']['telemetry_metric']['conf']['storage']['driver'] == 'file'
  # default store is file, so create needed directories with correct permissions
  # (on ubuntu they are created by the package, but owned by root and not writable
  # for gnocchi)
  store_path = node['openstack']['telemetry_metric']['conf']['storage']['file_basepath']
  %w(tmp measure cache).each do |dir|
    directory File.join(store_path, dir) do
      owner node['openstack']['telemetry_metric']['user']
      group node['openstack']['telemetry_metric']['group']
      recursive true
      mode '750'
    end
  end
end

# dbsync for gnocchi
execute 'run gnocchi-upgrade' do
  command "gnocchi-upgrade #{node['openstack']['telemetry_metric']['gnocchi-upgrade-options']}"
  user node['openstack']['telemetry_metric']['user']
  group node['openstack']['telemetry_metric']['group']
end

#### Start of Apache specific work

# Finds and appends the listen port to the apache2_install[openstack]
# resource which is defined in openstack-identity::server-apache.
apache_resource = find_resource(:apache2_install, 'openstack')

if apache_resource
  apache_resource.listen = [apache_resource.listen, "#{bind_service['host']}:#{bind_service['port']}"].flatten
else
  apache2_install 'openstack' do
    listen "#{bind_service['host']}:#{bind_service['port']}"
  end
end

apache2_mod_wsgi 'gnocchi'
apache2_module 'ssl' if node['openstack']['telemetry_metric']['ssl']['enabled']

# create the gnocchi-api apache directory
gnocchi_apache_dir = "#{default_docroot_dir}/gnocchi"
directory gnocchi_apache_dir do
  owner 'root'
  group 'root'
  mode '755'
end

gnocchi_server_entry = "#{gnocchi_apache_dir}/app"
# NOTE: Using lazy here as the wsgi file is not available until after
# the gnocchik-api package is installed during execution phase.
file gnocchi_server_entry do
  content lazy { IO.read(platform['gnocchi-api_wsgi_file']) }
  owner 'root'
  group 'root'
  mode '755'
end

template "#{apache_dir}/sites-available/gnocchi-api.conf" do
  extend Apache2::Cookbook::Helpers
  source 'wsgi-template.conf.erb'
  variables(
    daemon_process: 'gnocchi-api',
    server_host: bind_service['host'],
    server_port: bind_service['port'],
    server_entry: gnocchi_server_entry,
    run_dir: lock_dir,
    log_dir: default_log_dir,
    log_debug: node['openstack']['telemetry_metric']['debug'],
    user: node['openstack']['telemetry_metric']['user'],
    group: node['openstack']['telemetry_metric']['group'],
    use_ssl: node['openstack']['telemetry_metric']['ssl']['enabled'],
    cert_file: node['openstack']['telemetry_metric']['ssl']['certfile'],
    chain_file: node['openstack']['telemetry_metric']['ssl']['chainfile'],
    key_file: node['openstack']['telemetry_metric']['ssl']['keyfile'],
    ca_certs_path: node['openstack']['telemetry_metric']['ssl']['ca_certs_path'],
    cert_required: node['openstack']['telemetry_metric']['ssl']['cert_required'],
    protocol: node['openstack']['telemetry_metric']['ssl']['protocol'],
    ciphers: node['openstack']['telemetry_metric']['ssl']['ciphers']
  )
  notifies :restart, 'service[apache2]'
end

apache2_site 'gnocchi-api' do
  notifies :restart, 'service[apache2]', :immediately
end

service 'gnocchi-metricd' do
  service_name platform['gnocchi-metricd_service']
  subscribes :restart, "template[#{node['openstack']['telemetry_metric']['conf_file']}]"
  action [:enable, :start]
end
