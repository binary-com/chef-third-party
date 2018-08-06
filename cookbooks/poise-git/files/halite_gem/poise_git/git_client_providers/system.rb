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

require 'poise_languages'

require 'poise_git/git_client_providers/base'


module PoiseGit
  module GitClientProviders
    # A provider for `poise_git_client` to install from distro packages.
    #
    # @since 1.0.0
    # @see PoiseGit::Resources::PoiseGitClient::Resource
    # @provides poise_git_client
    class System < Base
      include PoiseLanguages::System::Mixin
      provides(:system)
      packages('git', {
        omnios: {default: %w{developer/versioning/git}},
        smartos: {default: %w{scmgit}},
      })

      # Output value for the Git binary we are installing.
      def git_binary
        # What should this be for OmniOS and SmartOS?
        "/usr/bin/git"
      end

      private

      # Install git from system packages.
      #
      # @return [void]
      def install_git
        install_system_packages do
          # Unlike language-ish packages, we don't need a headers package.
          dev_package false
        end
      end

      # Remove git from system packages.
      #
      # @return [void]
      def uninstall_git
        uninstall_system_packages do
          # Unlike language-ish packages, we don't need a headers package.
          dev_package false
        end
      end

      def system_package_candidates(version)
        # This is kind of silly, could use a refactor in the mixin but just
        # moving on for right now.
        node.value_for_platform(self.class.packages) || %w{git}
      end

    end
  end
end
