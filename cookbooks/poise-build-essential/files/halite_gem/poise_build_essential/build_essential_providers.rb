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

require 'chef/platform/provider_priority_map'

require 'poise_build_essential/build_essential_providers/debian'
require 'poise_build_essential/build_essential_providers/freebsd'
require 'poise_build_essential/build_essential_providers/mac_os_x'
require 'poise_build_essential/build_essential_providers/omnios'
require 'poise_build_essential/build_essential_providers/rhel'
require 'poise_build_essential/build_essential_providers/smartos'
require 'poise_build_essential/build_essential_providers/solaris'
require 'poise_build_essential/build_essential_providers/suse'
# require 'poise_build_essential/build_essential_providers/windows'


module PoiseBuildEssential
  # Inversion providers for the poise_build_essential resource.
  #
  # @since 1.0.0
  module BuildEssentialProviders
    # Set up priority maps
    Chef::Platform::ProviderPriorityMap.instance.priority(:poise_build_essential, [
      PoiseBuildEssential::BuildEssentialProviders::Debian,
      PoiseBuildEssential::BuildEssentialProviders::FreeBSD,
      PoiseBuildEssential::BuildEssentialProviders::MacOSX,
      PoiseBuildEssential::BuildEssentialProviders::OmniOS,
      PoiseBuildEssential::BuildEssentialProviders::RHEL,
      PoiseBuildEssential::BuildEssentialProviders::SmartOS,
      PoiseBuildEssential::BuildEssentialProviders::Solaris,
      PoiseBuildEssential::BuildEssentialProviders::SUSE,
      # PoiseBuildEssential::BuildEssentialProviders::Windows,
      PoiseBuildEssential::BuildEssentialProviders::Base,
    ])
  end
end
