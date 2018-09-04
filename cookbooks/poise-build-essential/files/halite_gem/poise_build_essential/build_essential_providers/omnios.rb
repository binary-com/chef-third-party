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
    # A provider for `poise_build_essential` to install on OmniOS platforms.
    #
    # @see PoiseBuildEssential::Resources::PoiseBuildEssential::Resource
    # @provides poise_build_essential
    class OmniOS < Base
      provides(:poise_build_essential, platform_family: 'omnios')

      private

      # (see Base#install_build_essential)
      def install_build_essential
        # Per OmniOS documentation, the gcc bin dir isn't in the default
        # $PATH, so add it to the running process environment.
        # http://omnios.omniti.com/wiki.php/DevEnv
        ENV['PATH'] = "#{ENV['PATH']}:/opt/gcc-4.7.2/bin"

        %w{developer/gcc48 developer/object-file developer/linker
           developer/library/lint developer/build/gnu-make system/header
           system/library/math/header-math}.map {|name| package name }
      end

    end
  end
end
