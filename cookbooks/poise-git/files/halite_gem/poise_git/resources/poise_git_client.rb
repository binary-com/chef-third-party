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

require 'chef/resource'
require 'poise'


module PoiseGit
  module Resources
    # (see PoiseGitClient::Resource)
    # @since 1.0.0
    module PoiseGitClient
      # A `poise_git_client` resource to install a C compiler and build tools.
      #
      # @provides poise_git_client
      # @action install
      # @action uninstall
      # @example
      #   poise_git_client 'git'
      class Resource < Chef::Resource
        include Poise(inversion: true, container: true)
        provides(:poise_git_client)
        actions(:install, :uninstall)

        # @!attribute version
        #   Version of Git to install. The version is prefix-matched so `'2'`
        #   will install the most recent Git 2.x, and so on.
        #   @return [String]
        #   @example Install any version
        #     poise_git_client 'any' do
        #       version ''
        #     end
        #   @example Install Git 2
        #     poise_git_client '2'
        attribute(:version, kind_of: String, default: lazy { default_version })

        # The path to the `git` binary for this Git installation. This is
        # an output property.
        #
        # @return [String]
        # @example
        #   execute "#{resources('poise_git_client[git]').git_binary} init"
        def git_binary
          provider_for_action(:git_binary).git_binary
        end

        # The environment variables for this Git installation. This is an
        # output property.
        #
        # @return [Hash<String, String>]
        def git_environment
          provider_for_action(:git_environment).git_environment
        end

        private

        # Default value for the version property. Trims an optional `git-` from
        # the resource name.
        #
        # @return [String]
        def default_version
          name[/^(git-?)?(.*)$/, 2] || ''
        end
      end

      # Providers can be found under git_client_providers/.
    end
  end
end
