#
# Cookbook:: openstack-integration-test
# Recipe:: run_tempest
#
# Copyright:: 2020-2021, Oregon State University
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

# Purpose: Run tempest like openstack-chef/Rakefile (used by kitchen)

execute 'run_tempest' do
  # Write log file to test VM's /root directory.
  command 'cd /opt/tempest; /opt/tempest-venv/tempest.sh'
  action :nothing
end

# Run tempest after everything else.
notify_group 'start_tempest' do
  notifies :run, 'execute[run_tempest]', :delayed
end
