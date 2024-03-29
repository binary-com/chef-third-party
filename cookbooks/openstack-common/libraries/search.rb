#
# Cookbook:: openstack-common
# library:: search
#
# Copyright:: 2013-2021, AT&T Services, Inc.
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

# Search methods
module ::Openstack
  # Search the nodes environment for the given role or recipe.
  #
  # @param [String] The role or recipe to be found.
  # @return [Array] The matching result or an empty list.
  def search_for(r, &block)
    role_query = "(chef_environment:#{node.chef_environment} AND roles:#{r})"
    recipe_query = "(chef_environment:#{node.chef_environment} AND recipes:#{r})".sub('::', '\:\:')
    query = "#{role_query} OR #{recipe_query}"
    count = 1
    sum = node['openstack']['common']['search_count_max']
    while count < sum
      resp = search(:node, query, &block)
      break unless resp.nil?
      sleep 2**count
      count += 1
    end
    resp || []
  end

  # Returns the value for ['openstack']['memcached_servers'] when
  # set, otherwise will perform a search.
  #
  # @param [String] role The role to be found (optional).
  # @return [Array] A list of memcached servers in format
  # '<ip>:<port>'.
  def memcached_servers(role = 'infra-caching')
    if node['openstack']['memcached_servers'].nil?
      search_for(role).map do |n|
        listen = n['memcached']['listen']
        port = n['memcached']['port'] || '11211'

        "#{listen}:#{port}"
      end.sort
    elsif node['openstack']['memcached_servers']
      node['openstack']['memcached_servers']
    else
      []
    end
  end

  # Returns all rabbit servers.
  # Uses the value for ['openstack']['mq']['servers'] when set, otherwise
  # will perform a search.
  #
  # @return [String] Rabbit servers joined by a comma in
  # the format of '<ip>:<port>'.
  def rabbit_servers
    if node['openstack']['mq']['servers']
      servers = node['openstack']['mq']['servers']
      port = node['openstack']['endpoints']['mq']['port']

      servers.map { |s| "#{s}:#{port}" }.join ','
    else
      role = node['openstack']['mq']['server_role']
      search_for(role).map do |n|
        # The listen attribute should be saved to the node
        # in the wrapper cookbook.  See the reference cookbook
        # openstack-ops-messaging.
        address = n['openstack']['mq']['listen']
        port = n['openstack']['endpoints']['mq']['port']

        "#{address}:#{port}"
      end.sort.join ','
    end
  end
end
