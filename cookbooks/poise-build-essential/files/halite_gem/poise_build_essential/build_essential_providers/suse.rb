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
    # A provider for `poise_build_essential` to install on SUSE platforms.
    #
    # @see PoiseBuildEssential::Resources::PoiseBuildEssential::Resource
    # @provides poise_build_essential
    class SUSE < Base
      provides(:poise_build_essential, platform_family: 'suse')

      private

      # (see Base#install_build_essential)
      def install_build_essential
        pkgs = %w{autoconf bison flex gcc gcc-c++ kernel-default-devel make m4}
        if node['platform_version'].to_i < 12
          pkgs += %w{gcc48 gcc48-c++}
        end
        package pkgs
      end

    end
  end
end
