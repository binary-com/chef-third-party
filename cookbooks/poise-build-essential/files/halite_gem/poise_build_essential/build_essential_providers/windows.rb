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
    # A provider for `poise_build_essential` to install on Windows platforms.
    #
    # @see PoiseBuildEssential::Resources::PoiseBuildEssential::Resource
    # @provides poise_build_essential
    class Windows < Base
      provides(:poise_build_essential, platform_family: 'windows')

      private

      # (see Base#install_build_essential)
      def install_build_essential
        install_build_essential_packages
      end

      # (see Base#upgrade_build_essential)
      def upgrade_build_essential
        # Upgrade and install are the same on Windows. (?)
        install_build_essential
      end

      # (see Base#remove_build_essential)
      def remove_build_essential
        raise NotImplementedError
      end

      # Install MSYS2 packages needed for the build environment.
      #
      # @api private
      # @return [Array<Chef::Resource>]
      def install_build_essential_packages
        # TODO This probably won't work on 32-bit right now, fix that.
        [
          'base-devel', # Brings down msys based bash/make/awk/patch/stuff.
          'mingw-w64-x86_64-toolchain', # Puts 64-bit SEH mingw toolchain in msys2\mingw64.
          'mingw-w64-i686-toolchain' # Puts 32-bit DW2 mingw toolchain in msys2\ming32.
        ].map do |pkg_group|
          # The pacman package provider doesn't support groups, so going old-school.
          poise_msys2_execute "pacman --sync #{pkg_group}" do
            command ['pacman', '--sync', '--noconfirm', '--noprogressbar', '--needed', pkg_group]
          end
        end
      end

    end
  end
end
