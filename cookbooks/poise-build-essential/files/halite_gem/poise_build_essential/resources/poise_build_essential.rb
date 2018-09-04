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


module PoiseBuildEssential
  module Resources
    # (see PoiseBuildEssential::Resource)
    # @since 1.0.0
    module PoiseBuildEssential
      # A `poise_build_essential` resource to install a C compiler and build tools.
      #
      # @provides poise_build_essential
      # @action install
      # @action upgrade
      # @action uninstall
      # @example
      #   poise_build_essential 'build-essential'
      class Resource < Chef::Resource
        include Poise
        provides(:poise_build_essential)
        actions(:install, :upgrade, :remove)

        # @!attribute allow_unsupported_platform
        #   Whether or not to raise an error on unsupported platforms.
        #   @return [Boolean]
        attribute(:allow_unsupported_platform, kind_of: [TrueClass, FalseClass], default: lazy { node['poise-build-essential']['allow_unsupported_platform'] })
      end

      # Providers can be found under build_essential_providers/.
    end
  end
end
