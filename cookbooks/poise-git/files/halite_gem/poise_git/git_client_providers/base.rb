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


module PoiseGit
  module GitClientProviders
    # The provider base class for `poise_git_client`.
    #
    # @see PoiseGit::Resources::PoiseGitClient::Resource
    # @provides poise_git_client
    class Base < Chef::Provider
      include Poise(inversion: :poise_git_client)
      provides(:poise_git_client)

      # Set default inversion options.
      #
      # @api private
      def self.default_inversion_options(node, new_resource)
        super.merge({
          version: new_resource.version,
        })
      end

      # The `install` action for the `poise_git_client` resource.
      #
      # @return [void]
      def action_install
        notifying_block do
          install_git
        end
      end

      # The `uninstall` action for the `poise_git_client` resource.
      #
      # @return [void]
      def action_uninstall
        notifying_block do
          uninstall_git
        end
      end

      # The path to the `git` binary. This is an output property.
      #
      # @abstract
      # @return [String]
      def git_binary
        raise NotImplementedError
      end

      # The environment variables for this Git. This is an output property.
      #
      # @return [Hash<String, String>]
      def git_environment
        {}
      end

      private

      # Install git.
      #
      # @abstract
      # @return [void]
      def install_git
        raise NotImplementedError
      end

      # Uninstall git.
      #
      # @abstract
      # @return [void]
      def uninstall_git
        raise NotImplementedError
      end

    end
  end
end
