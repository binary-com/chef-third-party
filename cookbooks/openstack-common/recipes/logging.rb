#
# Cookbook:: openstack-common
# library:: logging
#
# Copyright:: 2012-2021, AT&T Services, Inc.
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

directory '/etc/openstack' do
  owner 'root'
  group 'root'
  mode '755'
  action :create
end

template '/etc/openstack/logging.conf' do
  source 'logging.conf.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables(
    loggers: node['openstack']['logging']['loggers'],
    formatters: node['openstack']['logging']['formatters'],
    handlers: node['openstack']['logging']['handlers']
  )
end
