#
# Cookbook:: openstack-orchestration
# Attributes:: default
#
# Copyright:: 2013-2021, IBM Corp.
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

%w(public internal).each do |ep_type|
  # openstack orchestration-api service endpoints (used by users and services)
  default['openstack']['endpoints'][ep_type]['orchestration-api']['host'] = '127.0.0.1'
  default['openstack']['endpoints'][ep_type]['orchestration-api']['scheme'] = 'http'
  default['openstack']['endpoints'][ep_type]['orchestration-api']['path'] = '/v1/%(tenant_id)s'
  default['openstack']['endpoints'][ep_type]['orchestration-api']['port'] = 8004
  # openstack orchestration-api-cfn service endpoints (used by users and services)
  default['openstack']['endpoints'][ep_type]['orchestration-api-cfn']['host'] = '127.0.0.1'
  default['openstack']['endpoints'][ep_type]['orchestration-api-cfn']['scheme'] = 'http'
  default['openstack']['endpoints'][ep_type]['orchestration-api-cfn']['path'] = '/v1'
  default['openstack']['endpoints'][ep_type]['orchestration-api-cfn']['port'] = 8000
end
default['openstack']['bind_service']['all']['orchestration-api']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['orchestration-api']['port'] = 8004
default['openstack']['bind_service']['all']['orchestration-api-cfn']['host'] = '127.0.0.1'
default['openstack']['bind_service']['all']['orchestration-api-cfn']['port'] = 8000

# Set to some text value if you want templated config files
# to contain a custom banner at the top of the written file
default['openstack']['orchestration']['custom_template_banner'] = '
# This file is automatically generated by Chef
# Any changes will be overwritten
'

default['openstack']['orchestration']['syslog']['use']

# This is the name of the Chef role that will install the Keystone Service API
default['openstack']['orchestration']['identity_service_chef_role'] = 'os-identity'

# The name of the Chef role that knows about the message queue server
# that Heat uses
default['openstack']['orchestration']['rabbit_server_chef_role'] = 'os-ops-messaging'

default['openstack']['orchestration']['service_role'] = 'service'

default['openstack']['orchestration']['ec2authtoken']['auth']['version'] = 'v2.0'

# platform-specific settings
case node['platform_family']
when 'rhel'
  default['openstack']['orchestration']['user'] = 'heat'
  default['openstack']['orchestration']['group'] = 'heat'
  default['openstack']['orchestration']['platform'] = {
    'heat_common_packages' => %w(openstack-heat-common),
    'heat_api_packages' => %w(openstack-heat-api),
    'heat_dashboard_packages' => %w(openstack-heat-ui),
    'heat_api_service' => 'openstack-heat-api',
    'heat_api_cfn_packages' => %w(openstack-heat-api-cfn),
    'heat_api_cfn_service' => 'openstack-heat-api-cfn',
    'heat_engine_packages' => %w(openstack-heat-engine),
    'heat_engine_service' => 'openstack-heat-engine',
    'heat_api_process_name' => 'heat-api',
    'package_overrides' => '',
  }
when 'debian'
  default['openstack']['orchestration']['user'] = 'heat'
  default['openstack']['orchestration']['group'] = 'heat'
  default['openstack']['orchestration']['platform'] = {
    'heat_common_packages' => %w(heat-common python3-heat),
    'heat_api_packages' => %w(heat-api),
    'heat_dashboard_packages' => %w(python3-heat-dashboard),
    'heat_api_service' => 'heat-api',
    'heat_api_cfn_packages' => %w(heat-api-cfn),
    'heat_api_cfn_service' => 'heat-api-cfn',
    'heat_engine_packages' => %w(heat-engine),
    'heat_engine_service' => 'heat-engine',
    'package_overrides' => '',
  }
end
