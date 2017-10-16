#
# Copyright 2017, Noah Kantrowitz
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
require 'poise'


module PoiseBuildEssential
  module BuildEssentialProviders
    # The provider base class for `poise_build_essential`.
    #
    # @see PoiseBuildEssential::Resources::PoiseBuildEssential::Resource
    # @provides poise_build_essential
    class Base < Chef::Provider
      include Poise
      provides(:poise_build_essential)

      # The `install` action for the `poise_build_essential` resource.
      #
      # @return [void]
      def action_install
        notifying_block do
          install_build_essential
        end
      end

      # The `upgrade` action for the `poise_build_essential` resource.
      #
      # @return [void]
      def action_upgrade
        notifying_block do
          upgrade_build_essential
        end
      end

      # The `remove` action for the `poise_build_essential` resource.
      #
      # @return [void]
      def action_remove
        notifying_block do
          remove_build_essential
        end
      end

      private

      # Install C compiler and build tools. Must be implemented by subclasses.
      #
      # @abstract
      def install_build_essential
        unsupported_platform("Unknown platform for poise_build_eseential: #{node['platform']} (#{node['platform_family']})")
        # Return an array so upgrade/remove also work.
        []
      end

      # Upgrade C compiler and build tools. Must be implemented by subclasses.
      #
      # @abstract
      def upgrade_build_essential
        install_build_essential.tap do |installed|
          Array(installed).each {|r| r.action(:upgrade) }
        end
      end

      # Uninstall C compiler and build tools. Must be implemented by subclasses.
      #
      # @abstract
      def remove_build_essential
        install_build_essential.tap do |installed|
          Array(installed).each {|r| r.action(:remove) }
        end
      end

      # Helper method for either warning about an unsupported platform or raising
      # an exception.
      #
      # @api private
      # @param msg [String] Error message to display.
      # @return [void]
      def unsupported_platform(msg)
        if new_resource.allow_unsupported_platform
          Chef::Log.warn(msg)
        else
          raise RuntimeError.new(msg)
        end
      end

    end
  end
end
