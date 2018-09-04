#
# Copyright 2008-2017, Chef Software, Inc.
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

require 'poise_build_essential/build_essential_providers/base'


module PoiseBuildEssential
  module BuildEssentialProviders
    # A provider for `poise_build_essential` to install on macOS platforms.
    #
    # @see PoiseBuildEssential::Resources::PoiseBuildEssential::Resource
    # @provides poise_build_essential
    class MacOSX < Base
      provides(:poise_build_essential, platform_family: 'mac_os_x')

      private

      # (see Base#install_build_essential)
      def install_build_essential
        # This script was graciously borrowed and modified from Tim Sutton's
        # osx-vm-templates at https://github.com/timsutton/osx-vm-templates/blob/b001475df54a9808d3d56d06e71b8fa3001fff42/scripts/xcode-cli-tools.sh
        execute 'install XCode Command Line tools' do
          command <<-EOH
# create the placeholder file that's checked by CLI updates' .dist code
# in Apple's SUS catalog
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
# find the CLI Tools update
PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
# install it
softwareupdate -i "$PROD" --verbose
# Remove the placeholder to prevent perpetual appearance in the update utility
rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
          EOH
          not_if 'pkgutil --pkgs=com.apple.pkg.CLTools_Executables'
        end
      end

      # (see Base#upgrade_build_essential)
      def upgrade_build_essential
        # Make upgrade the same as install on Mac.
        install_build_essential
      end

      # (see Base#remove_build_essential)
      def remove_build_essential
        # Not sure how to do this, ignoring for now.
        raise NotImplementedError
      end

    end
  end
end
