#
# Cookbook:: openstack-integration-test
# Recipe:: setup
#
# Copyright:: 2014-2021, Rackspace US, Inc.
# Copyright:: 2017-2021, Oregon State university
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Chef::Recipe
  include ::Openstack
end

class Chef::Resource::RubyBlock
  include ::Openstack
end

platform_options = node['openstack']['integration-test']['platform']
service_available = node['openstack']['integration-test']['conf']['service_available']

package platform_options['tempest_packages'] do
  options platform_options['package_overrides']
  action :upgrade
end

identity_endpoint = internal_endpoint 'identity'
auth_url = identity_endpoint.to_s

admin_user = node['openstack']['identity']['admin_user']
admin_pass = get_password 'user', admin_user
admin_project = node['openstack']['identity']['admin_project']
admin_domain = node['openstack']['identity']['admin_domain_name']
admin_project_domain_name = node['openstack']['identity']['admin_project_domain']
endpoint_type = node['openstack']['identity']['endpoint_type']

connection_params = {
  openstack_auth_url: auth_url,
  openstack_username: admin_user,
  openstack_api_key: admin_pass,
  openstack_project_name: admin_project,
  openstack_domain_name: admin_domain,
  openstack_endpoint_type: endpoint_type,
}

%w(user1 user2).each do |user|
  service_user = node['openstack']['integration-test'][user]['user_name']
  service_project = node['openstack']['integration-test'][user]['project_name']
  service_role = node['openstack']['integration-test'][user]['role']
  service_domain = node['openstack']['integration-test'][user]['domain_name']
  service_pass = node['openstack']['integration-test'][user]['password']

  openstack_project service_project do
    connection_params connection_params
  end

  openstack_user service_user do
    role_name service_role
    project_name service_project
    domain_name service_domain
    password service_pass
    connection_params connection_params
    action [:create, :grant_role, :grant_domain]
  end
end

openstack_role node['openstack']['integration-test']['heat_stack_user_role'] do
  connection_params connection_params
  only_if { service_available['heat'] }
end

include_recipe 'openstack-common'
build_essential 'tempest'

tempest_path = '/opt/tempest'
venv_path = '/opt/tempest-venv'

case node['platform_family']
when 'debian'
  venv_cmd = 'virtualenv -p python3'
when 'fedora', 'rhel'
  venv_cmd = 'virtualenv'
end

execute 'create virtualenv for tempest' do
  command "#{venv_cmd} #{venv_path}"
  creates venv_path
end

if platform_family?('rhel') && node['platform_version'].to_i == 7
  # TODO(ramereth): RDO Train ships a cacert.pem which contains the expired LetsEncrypt root cert
  cookbook_file "#{venv_path}/lib/python2.7/site-packages/pip/_vendor/requests/cacert.pem"
end

# Note(jh): Make sure to keep the constraint definition in sync with
# the tempest version
tempest_ver = '22.1.0'
constraint = '-c https://opendev.org/openstack/requirements/raw/branch/stable/train/upper-constraints.txt'

execute 'install tempest' do
  action :nothing
  command "#{venv_path}/bin/pip install #{constraint} tempest==#{tempest_ver}"
  cwd tempest_path
end

git tempest_path do
  repository 'https://opendev.org/openstack/tempest'
  reference tempest_ver
  depth 1
  action :sync
  notifies :run, 'execute[install tempest]', :immediately
end

template "#{venv_path}/tempest.sh" do
  source 'tempest.sh.erb'
  user 'root'
  group 'root'
  mode '755'
  variables(
    venv_path: venv_path
  )
end

%w(image1 image2).each do |img|
  image_name = node['openstack']['integration-test'][img]['name']
  image_id = node['openstack']['integration-test'][img]['id']
  openstack_image_image img do
    identity_user admin_user
    identity_pass admin_pass
    identity_tenant admin_project
    identity_uri auth_url
    identity_user_domain_name admin_domain
    identity_project_domain_name admin_project_domain_name
    image_name image_name
    image_id image_id
    image_url node['openstack']['integration-test'][img]['source']
    only_if { service_available['glance'] }
  end
end

# NOTE: This has to be done in a ruby_block so it gets executed at execution
#       time and not compile time (when nova does not yet exist).
ruby_block 'Create nano flavor 99' do
  block do
    begin
      env = openstack_command_env(admin_user, admin_project, 'Default', 'Default')
      output = openstack_command('openstack', 'flavor list', env)
      unless output.include? 'm1.nano'
        openstack_command('openstack', 'flavor create --id 99 --vcpus 1 --ram 64 --disk 1 m1.nano', env)
      end
    rescue RuntimeError => e
      Chef::Log.error("Could not create flavor m1.nano. Error was #{e.message}")
    end
  end
  only_if { service_available['nova'] }
end

node.default['openstack']['integration-test']['conf'].tap do |conf|
  conf['compute']['image_ref'] = node['openstack']['integration-test']['image1']['id']
  conf['compute']['image_ref_alt'] = node['openstack']['integration-test']['image2']['id']
  conf['identity']['uri_v3'] = identity_endpoint.to_s
  conf['identity']['v3_endpoint_type'] = endpoint_type
end

node.default['openstack']['integration-test']['conf_secrets'].tap do |conf_secrets|
  conf_secrets['auth']['admin_username'] = admin_user
  conf_secrets['auth']['admin_password'] = admin_pass
  conf_secrets['auth']['admin_project_name'] = admin_project
end

# merge all config options and secrets to be used in the tempest.conf.erb
integration_test_conf_options = merge_config_options 'integration-test'

template '/opt/tempest/etc/tempest-blacklist'

# create the keystone.conf from attributes
template '/opt/tempest/etc/tempest.conf' do
  source 'openstack-service.conf.erb'
  cookbook 'openstack-common'
  owner 'root'
  group 'root'
  mode '600'
  variables(
    service_config: integration_test_conf_options
  )
end

directory '/opt/tempest/logs' do
  owner 'root'
  group 'root'
  mode '755'
  action :create
end

# execute discover_hosts again before running tempest
execute 'discover_hosts' do
  user node['openstack']['integration-test']['nova_user']
  group node['openstack']['integration-test']['nova_group']
  command 'nova-manage cell_v2 discover_hosts'
  only_if { service_available['nova'] }
end

# delete all secrets saved in the attribute
# node['openstack']['identity']['conf_secrets'] after creating the keystone.conf
ruby_block "delete all attributes in node['openstack']['integration-test']['conf_secrets']" do
  block do
    node.rm(:openstack, :'integration-test', :conf_secrets)
  end
end
