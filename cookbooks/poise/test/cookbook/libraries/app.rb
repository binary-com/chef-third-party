#
# Copyright 2013-2016, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider'
require 'chef/resource'

require 'poise'


module PoiseTest
  module App
    class Resource < Chef::Resource
      include Poise(container: true)
      provides(:app)
      actions(:install)

      attribute(:path, kind_of: String, name_attribute: true)
      attribute(:user, kind_of: String, default: 'root')
      attribute(:group, kind_of: String, default: 'root')
    end

    class Provider < Chef::Provider
      include Poise
      provides(:app)

      def action_install
        notifying_block do
          directory new_resource.path do
            owner new_resource.user
            group new_resource.group
            mode '755'
          end
        end
      end
    end

  end
end
