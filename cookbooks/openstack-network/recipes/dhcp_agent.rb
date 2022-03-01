#
# Cookbook:: openstack-network
# Recipe:: dhcp_agent
#
# Copyright:: 2013, AT&T
# Copyright:: 2020, Oregon State University
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

include_recipe 'openstack-network'

platform_options = node['openstack']['network']['platform']

package platform_options['neutron_dhcp_packages'] do
  options platform_options['package_overrides']
  action :upgrade
end

# TODO: (jklare) this should be refactored and probably pull in the some dnsmasq
# cookbook to do the proper configuration
template '/etc/neutron/dnsmasq.conf' do
  source 'dnsmasq.conf.erb'
  owner node['openstack']['network']['platform']['user']
  group node['openstack']['network']['platform']['group']
  mode '644'
end

service_config = merge_config_options 'network_dhcp'
template node['openstack']['network_dhcp']['config_file'] do
  source 'openstack-service.conf.erb'
  cookbook 'openstack-common'
  owner node['openstack']['network']['platform']['user']
  group node['openstack']['network']['platform']['group']
  mode '644'
  variables(
    service_config: service_config
  )
end

# TODO: (jklare) this should be refactored and probably pull in the some dnsmasq
# cookbook to do the proper configuration
if platform?('centos')
  rpm_package 'dnsmasq' do
    action :upgrade
  end
end

service 'neutron-dhcp-agent' do
  service_name platform_options['neutron_dhcp_agent_service']
  supports status: true, restart: true
  action [:enable, :start]
  subscribes :restart, [
    'template[/etc/neutron/neutron.conf]',
    'template[/etc/neutron/dnsmasq.conf]',
    "template[#{node['openstack']['network_dhcp']['config_file']}]",
    'rpm_package[dnsmasq]',
  ]
end
