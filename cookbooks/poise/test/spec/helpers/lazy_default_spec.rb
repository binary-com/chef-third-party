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

LAZY_DEFAULT_GLOBAL = [0]

describe Poise::Helpers::LazyDefault do
  resource(:poise_test) do
    include Poise::Helpers::LWRPPolyfill
    include described_class
    attribute(:value, default: lazy { name + '_lazy' })
  end
  provider(:poise_test)
  recipe do
    poise_test 'test'
  end

  it { is_expected.to run_poise_test('test').with(value: 'test_lazy') }

  context 'with an explicit value' do
    recipe do
      poise_test 'test' do
        value 'value'
      end
    end

    it { is_expected.to run_poise_test('test').with(value: 'value') }
  end # /context with an explicit value

  context 'in a subclass' do
    resource(:poise_sub, parent: :poise_test)
    provider(:poise_sub)
    recipe do
      poise_sub 'test'
    end

    it { is_expected.to run_poise_sub('test').with(value: 'test_lazy') }
  end # /context in a subclass

  context 'with an external global' do
    resource(:poise_test) do
      include Poise::Helpers::LWRPPolyfill
      include described_class
      attribute(:value, default: lazy { LAZY_DEFAULT_GLOBAL.first })
    end

    it 'does not cache the value before retrieval' do
      LAZY_DEFAULT_GLOBAL[0] = 42
      is_expected.to run_poise_test('test').with(value: 42)
    end

    # This is actually part of set_or_return, but make sure we didn't break semantics
    it 'caches the value once retrieved' do
      LAZY_DEFAULT_GLOBAL[0] = 0
      is_expected.to run_poise_test('test').with(value: 0)
      LAZY_DEFAULT_GLOBAL[0] = 42
      is_expected.to run_poise_test('test').with(value: 0)
    end
  end # /context with an external global

  context 'with a mutable value' do
    resource(:poise_test) do
      include Poise::Helpers::LWRPPolyfill
      include described_class
      attribute(:value, default: lazy { [] })
    end
    recipe do
      poise_test 'test' do
        value << 1
        value << 2
      end
    end

    it { is_expected.to run_poise_test('test').with(value: [1, 2]) }
  end # /context with a mutable value

  context 'with a broken default' do
    resource(:poise_test) do
      include Poise::Helpers::LWRPPolyfill
      include described_class
      attribute(:value, default: lazy { raise RuntimeError })
    end
    provider(:poise_test) do
      def action_run
        new_resource.value
      end
    end

    context 'with no value' do
      recipe do
        poise_test 'test'
      end

      it { expect { subject }.to raise_error RuntimeError }
    end # /context with no value

    context 'with true' do
      recipe do
        poise_test 'test' do
          value true
        end
      end

      it { is_expected.to run_poise_test('test') }
    end # /context with true

    context 'with false' do
      recipe do
        poise_test 'test' do
          value false
        end
      end

      it { is_expected.to run_poise_test('test') }
    end # /context with false
  end # /context with a broken default
end
