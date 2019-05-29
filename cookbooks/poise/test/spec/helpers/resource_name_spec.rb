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

class ResourceNameHelper < Chef::Resource
  include Poise::Helpers::ResourceName
  provides(:provides_test)
end

# Helper for testing multiple names.
class ResourceNameHelperTwo < Chef::Resource
  include Poise::Helpers::ResourceName
  provides(:provides_test_two)
  provides(:provides_test_2)
end

describe Poise::Helpers::ResourceName do
  context 'via class.name' do
    resource(:poise_test, auto: false) do
      include described_class
    end
    subject { resource(:poise_test).new(nil, nil).resource_name }

    it { is_expected.to eq :poise_test }
  end # /context via class.name

  context 'via provides' do
    subject { ResourceNameHelper.new(nil, nil).resource_name }

    it { is_expected.to eq :provides_test }
  end # /context via provides

  context 'with multiple names' do
    subject { ResourceNameHelperTwo.new(nil, nil).resource_name }

    it { is_expected.to eq :provides_test_two }
  end # /context with multiple names
end
