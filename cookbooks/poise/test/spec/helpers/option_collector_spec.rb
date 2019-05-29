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

describe Poise::Helpers::OptionCollector do
  resource(:poise_test) do
    include described_class
    attribute(:options, option_collector: true)
  end
  provider(:poise_test)

  context 'with a block' do
    recipe do
      poise_test 'test' do
        options do
          one '1'
          two 2
        end
      end
    end

    it { is_expected.to run_poise_test('test').with(options: {'one' => '1', 'two' => 2}) }
  end # /context with a block

  context 'with a hash' do
    recipe do
      poise_test 'test' do
        options one: '1', two: 2
      end
    end

    it { is_expected.to run_poise_test('test').with(options: {'one' => '1', 'two' => 2}) }
  end # /context with a hash

  context 'with both a block and a hash' do
    recipe do
      poise_test 'test' do
        options one: '1', two: 2 do
          two 3
          three 'three'
        end
      end
    end

    it { is_expected.to run_poise_test('test').with(options: {'one' => '1', 'two' => 3, 'three' => 'three'}) }
  end # /context with both a block and a hash

  context 'with a normal attribute too' do
    resource(:poise_test) do
      include Poise::Helpers::LWRPPolyfill
      include described_class
      attribute(:options, option_collector: true)
      attribute(:value)
    end
    recipe do
      poise_test 'test' do
        options do
          one '1'
        end
        value 2
      end
    end

    it { is_expected.to run_poise_test('test').with(options: {'one' => '1'}, value: 2) }
  end # /context with a normal attribute too

  context 'with an invalid key' do
    recipe do
      poise_test 'test' do
        options do
          one two
        end
      end
    end

    it { expect { subject }.to raise_error NoMethodError }
  end # /context with an invalid key

  describe 'parser' do
    context 'with a parser Proc' do
      resource(:poise_test) do
        include Poise::Helpers::LWRPPolyfill
        include described_class
        attribute(:options, option_collector: true, parser: proc {|val| parse(val) })
        def parse(val)
          {name: val}
        end
      end
      recipe do
        poise_test 'test' do
          options '1'
        end
      end

      it { is_expected.to run_poise_test('test').with(options: {'name' => '1'}) }
    end # /context with a parser Proc

    context 'with a parser Symbol' do
      resource(:poise_test) do
        include Poise::Helpers::LWRPPolyfill
        include described_class
        attribute(:options, option_collector: true, parser: :parse)
        def parse(val)
          {name: val}
        end
      end
      recipe do
        poise_test 'test' do
          options '1'
        end
      end

      it { is_expected.to run_poise_test('test').with(options: {'name' => '1'}) }
    end # /context with a parser Symbol

    context 'with an invalid parser' do
      it do
        expect do
          resource(:poise_test).send(:attribute, :options, option_collector: true, parser: 'invalid')
        end.to raise_error(Poise::Error)
      end
    end # /context with an invalid parser
  end # /describe parser

  describe 'forced_keys' do
    resource(:poise_test) do
      include described_class
      def foo(*args)
        'foo'
      end
      attribute(:options, option_collector: true)
    end
    recipe do
      poise_test 'test' do
        options do
          foo 'bar'
        end
      end
    end

    context 'without forced_keys' do
      it { is_expected.to run_poise_test('test').with(options: {}) }
    end # /context without forced_keys

    context 'with forced_keys' do
      resource(:poise_test) do
        include described_class
        def foo(*args)
          'foo'
        end
        attribute(:options, option_collector: true, forced_keys: %i{foo})
      end
      it { is_expected.to run_poise_test('test').with(options: {'foo' => 'bar'}) }
    end # /context with forced_keys

    context 'with implicit forced_keys' do
      recipe do
        poise_test 'test' do
          options do
            name 'bar'
          end
        end
      end
      it { is_expected.to run_poise_test('test').with(options: {'name' => 'bar'}) }
      it { is_expected.to_not run_poise_test('bar') }
    end # /context with forced_keys
  end # /describe forced_keys

  # TODO: Write tests for mixed symbol/string data
end
