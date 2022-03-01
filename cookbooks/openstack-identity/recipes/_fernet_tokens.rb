#
# Cookbook:: openstack-identity
# Recipe:: _fernet_tokens
#
# Copyright:: 2020, Oregon State University
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

# This recipe is automatically included in openstack-identity::service-apache.
# It will add the needed configuration options to the keystone.conf and create
# the needed fernet keys from predefined secrets (e.g. encrypted data bags or vaults).

class ::Chef::Recipe
  include ::Openstack
end

key_repository = node['openstack']['identity']['conf']['fernet_tokens']['key_repository']
keystone_user = node['openstack']['identity']['user']
keystone_group = node['openstack']['identity']['group']

directory key_repository do
  owner keystone_user
  group keystone_group
  mode '700'
end

node['openstack']['identity']['fernet']['keys'].each do |key_index|
  key = secret(node['openstack']['secret']['secrets_data_bag'], "fernet_key#{key_index}")
  file File.join(key_repository, key_index.to_s) do
    content key
    owner keystone_user
    group keystone_group
    mode '400'
    sensitive true
  end
end

execute 'keystone-manage fernet_setup' do
  command "keystone-manage fernet_setup --keystone-user #{keystone_user} --keystone-group #{keystone_group}"
  creates '/etc/keystone/fernet-keys'
end
