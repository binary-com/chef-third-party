#
# Cookbook:: openstack-network
# Recipe:: ml2_linuxbridge
#
# Copyright:: 2013-2021, AT&T
# Copyright:: 2016-2021, Oregon State University
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

# TODO: (jklare) This recipe is a WIP one, since we probably want to support
# ml2_linuxbridge, but are not testing it right now. It will install the needed
# packages on debian and rhel/fedora, set the proper ml2 mechanism_drivers and
# set the proper attributes to create an empty linuxbridge_conf.ini in the
# proper directory when including the plugin_conf recipe in this cookbook. The
# config can be filled via attributes (e.g. like done for the ml2_openvswitch).
include_recipe 'openstack-network'
node.default['openstack']['network']['plugins']['ml2']['conf']['ml2']['type_drivers'] = 'local,flat,vlan,gre,vxlan'
node.default['openstack']['network']['plugins']['ml2']['conf']['ml2']['mechanism_drivers'] = 'linuxbridge,l2population'
node.default['openstack']['network']['plugins']['ml2']['conf']['ml2_type_vxlan']['vni_ranges'] = 'VNI_START:VNI_END'

platform_options = node['openstack']['network']['platform']

package platform_options['neutron_linuxbridge_agent_packages'] do
  options platform_options['package_overrides']
  action :upgrade
end

node.default['openstack']['network']['plugins']['linuxbridge'].tap do |lb|
  lb['path'] = '/etc/neutron/plugins/ml2'
  lb['filename'] = 'linuxbridge_agent.ini'
  lb['conf']['securitygroup']['firewall_driver'] = 'neutron.agent.linux.iptables_firewall.IptablesFirewallDriver'
end

include_recipe 'openstack-network::plugin_config'

service 'neutron-plugin-linuxbridge-agent' do
  service_name platform_options['neutron_linuxbridge_agent_service']
  supports status: true, restart: true
  action [:enable, :start]
  subscribes :restart,
    [
      'template[/etc/neutron/neutron.conf]',
      'template[/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini]',
    ]
end
