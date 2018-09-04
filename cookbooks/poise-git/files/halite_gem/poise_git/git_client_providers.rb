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

require 'poise_git/git_client_providers/dummy'
require 'poise_git/git_client_providers/system'


module PoiseGit
  # Inversion providers for the poise_git resource.
  #
  # @since 1.0.0
  module GitClientProviders
    autoload :Base, 'poise_git/git_client_providers/base'

    # Set up priority maps
    Chef::Platform::ProviderPriorityMap.instance.priority(:poise_git_client, [
      PoiseGit::GitClientProviders::Dummy,
      PoiseGit::GitClientProviders::System,
    ])
  end
end
