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
    # A provider for `poise_build_essential` to install on Solaris platforms.
    #
    # @see PoiseBuildEssential::Resources::PoiseBuildEssential::Resource
    # @provides poise_build_essential
    class Solaris < Base
      provides(:poise_build_essential, platform_family: 'solaris2')

      private

      # (see Base#install_build_essential)
      def install_build_essential
        if node['platform_version'].to_f < 5.11
          unsupported_platform('poise_build_essential does not support Solaris before 11. You will need to install SUNWbison, SUNWgcc, SUNWggrp, SUNWgmake, and SUNWgtar from the Solaris DVD')
          return []
        end

        # lock because we don't use gcc 5 yet.
        [package('gcc') { version '4.8.2'} ] + \
        %w{autoconf automake bison gnu-coreutils flex gcc-3 gnu-grep gnu-make
           gnu-patch gnu-tar make pkg-config ucb}.map {|name| package name }
      end

    end
  end
end
