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
  module AppConfig
    class Resource < Chef::Resource
      include Poise(:app)
      provides(:app_config)
      actions(:create)

      attribute('', template: true, required: true)
      attribute(:config_name, kind_of: String, default: lazy { name.split('::').last })

      def path
        ::File.join(parent.path, config_name+'.conf')
      end
    end

    class Provider < Chef::Provider
      include Poise
      provides(:app_config)

      def action_create
        notifying_block do
          file new_resource.path do
            owner new_resource.parent.user
            group new_resource.parent.group
            mode '644'
            content new_resource.content
          end
        end
      end
    end

  end
end
