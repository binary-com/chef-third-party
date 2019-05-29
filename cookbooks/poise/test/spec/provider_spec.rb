#
# Copyright 2015-2016, Noah Kantrowitz
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

require 'spec_helper'

describe Poise::Provider do
  provider(:poise_test) do
    include described_class
  end
  subject { provider(:poise_test) }

  it { is_expected.to include(Poise::Helpers::IncludeRecipe) }
  it { is_expected.to include(Poise::Helpers::LWRPPolyfill) }
  it { is_expected.to include(Poise::Helpers::NotifyingBlock) }
end
