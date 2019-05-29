#
# Copyright 2013-2016, Noah Kantrowitz
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

describe Poise do
  context 'with a Resource' do
    resource(:poise_test) do
      include Poise
    end
    subject { resource(:poise_test) }

    it { is_expected.to include Poise::Resource }
    it { is_expected.to include Poise::Helpers::LazyDefault }
    it { is_expected.to include Poise::Helpers::LWRPPolyfill }
    it { is_expected.to include Poise::Helpers::LWRPPolyfill::Resource }
    it { is_expected.to include Poise::Helpers::OptionCollector }
    it { is_expected.to include Poise::Helpers::ResourceName }
    it { is_expected.to include Poise::Helpers::TemplateContent }
    it { is_expected.to include Poise::Helpers::ChefspecMatchers }

    context 'as a function call' do
      context 'with no arguments' do
        resource(:poise_test) do
          include Poise()
        end

        it { is_expected.to include Poise }
        it { is_expected.to include Poise::Resource }
      end # /context with no arguments

      context 'with a parent class' do
        resource(:poise_test) do
          include Poise(parent: Chef::Resource::RubyBlock)
        end

        it { is_expected.to include Poise }
        it { is_expected.to include Poise::Resource }
        it { is_expected.to include Poise::Helpers::Subresources::Child }
        its(:parent_type) { is_expected.to eq Chef::Resource::RubyBlock }
        its(:parent_optional) { is_expected.to be_falsey }
      end # /context with a parent class

      context 'with a parent class shortcut' do
        resource(:poise_test) do
          include Poise(Chef::Resource::RubyBlock)
        end

        it { is_expected.to include Poise }
        it { is_expected.to include Poise::Resource }
        it { is_expected.to include Poise::Helpers::Subresources::Child }
        its(:parent_type) { is_expected.to eq Chef::Resource::RubyBlock }
        its(:parent_optional) { is_expected.to be_falsey }
      end # /context with a parent class shortcut

      context 'with an optional parent' do
        resource(:poise_test) do
          include Poise(parent: Chef::Resource::RubyBlock, parent_optional: true)
        end

        it { is_expected.to include Poise }
        it { is_expected.to include Poise::Resource }
        it { is_expected.to include Poise::Helpers::Subresources::Child }
        its(:parent_type) { is_expected.to eq Chef::Resource::RubyBlock }
        its(:parent_optional) { is_expected.to be_truthy }
      end # /context with an optional parent

      context 'with a container' do
        resource(:poise_test) do
          include Poise(container: true)
        end

        it { is_expected.to include Poise }
        it { is_expected.to include Poise::Resource }
        it { is_expected.to include Poise::Helpers::Subresources::Container }
      end # /context with a container

      context 'with a container namespace' do
        resource(:poise_test) do
          include Poise(container: true, container_namespace: true)
        end

        it { is_expected.to include Poise }
        it { is_expected.to include Poise::Resource }
        it { is_expected.to include Poise::Helpers::Subresources::Container }
        its(:container_namespace) { is_expected.to eq true }
      end # /context with a container namespace

      context 'with a container namespace as a string' do
        resource(:poise_test) do
          include Poise(container: true, container_namespace: 'example')
        end

        it { is_expected.to include Poise }
        it { is_expected.to include Poise::Resource }
        it { is_expected.to include Poise::Helpers::Subresources::Container }
        its(:container_namespace) { is_expected.to eq 'example' }
      end # /context with a container namespaceas a string

      context 'with a container namespace as a proc' do
        resource(:poise_test) do
          include Poise(container: true, container_namespace: Proc.new { name })
        end

        it { is_expected.to include Poise }
        it { is_expected.to include Poise::Resource }
        it { is_expected.to include Poise::Helpers::Subresources::Container }
        its(:container_namespace) { is_expected.to be_a Proc }
      end # /context with a container namespaceas a proc

      context 'with a no container namespace' do
        resource(:poise_test) do
          include Poise(container: true, container_namespace: false)
        end

        it { is_expected.to include Poise }
        it { is_expected.to include Poise::Resource }
        it { is_expected.to include Poise::Helpers::Subresources::Container }
        its(:container_namespace) { is_expected.to eq false }
      end # /context with no container namespace

      context 'with both a parent and a container' do
        resource(:poise_test) do
          include Poise(parent: Chef::Resource::RubyBlock, container: true)
        end

        it { is_expected.to include Poise }
        it { is_expected.to include Poise::Resource }
        it { is_expected.to include Poise::Helpers::Subresources::Child }
        it { is_expected.to include Poise::Helpers::Subresources::Container }
        its(:parent_type) { is_expected.to eq Chef::Resource::RubyBlock }
        its(:parent_optional) { is_expected.to be_falsey }
      end # /context with both a parent and a container

      context 'with fused' do
        resource(:poise_test) do
          include Poise(fused: true)
        end

        it { is_expected.to include Poise }
        it { is_expected.to include Poise::Resource }
        it { is_expected.to include Poise::Helpers::Fused }
      end # /context with fused
    end # /context as a function call
  end # /context for a Resource

  context 'with a Provider' do
    provider(:poise_test) do
      include Poise
    end
    subject { provider(:poise_test) }

    it { is_expected.to include Poise::Provider }
    it { is_expected.to include Poise::Helpers::IncludeRecipe }
    it { is_expected.to include Poise::Helpers::LWRPPolyfill }
    it { is_expected.to include Poise::Helpers::LWRPPolyfill::Provider }
    it { is_expected.to include Poise::Helpers::NotifyingBlock }

    context 'as a function call' do
      provider(:poise_test) do
        include Poise()
      end

      it { is_expected.to include Poise }
      it { is_expected.to include Poise::Provider }
    end # /context as a function call
  end # /context for a Provider

  it 'has a fake name when used a function' do
    expect(Poise().name).to eq 'Poise'
  end # /it has a fake name when used a function

  describe '.debug?' do
    let(:debug_files) { [] }
    before do
      allow(File).to receive(:exist?).and_call_original
      expect(File).to receive(:exist?).with(/\/poise_debug/i).twice {|path| debug_files.include?(path) }
    end
    around do |ex|
      # Reset the stat checks both before and after.
      begin
        Poise.remove_instance_variable(:@debug_file_upper) if Poise.instance_variable_defined?(:@debug_file_upper)
        Poise.remove_instance_variable(:@debug_file_lower) if Poise.instance_variable_defined?(:@debug_file_lower)
        ex.run
      ensure
        Poise.remove_instance_variable(:@debug_file_upper) if Poise.instance_variable_defined?(:@debug_file_upper)
        Poise.remove_instance_variable(:@debug_file_lower) if Poise.instance_variable_defined?(:@debug_file_lower)
      end
    end
    subject { described_class.debug?(chef_runner.node) }

    context 'with no flags' do
      it { is_expected.to be false }
    end # /context with no flags

    context 'with $POISE_DEBUG' do
      around do |ex|
        begin
          old = ENV['POISE_DEBUG']
          ENV['POISE_DEBUG'] = '1'
          ex.run
        ensure
          ENV['POISE_DEBUG'] = old
        end
      end

      it { is_expected.to be true }
    end # /context with $POISE_DEBUG

    context 'with $POISE_DEBUG = false' do
      around do |ex|
        begin
          old = ENV['POISE_DEBUG']
          ENV['POISE_DEBUG'] = 'false'
          ex.run
        ensure
          ENV['POISE_DEBUG'] = old
        end
      end

      it { is_expected.to be false }
    end # /context with $POISE_DEBUG = false

    context 'with $poise_debug' do
      around do |ex|
        begin
          old = ENV['poise_debug']
          ENV['poise_debug'] = '1'
          ex.run
        ensure
          ENV['poise_debug'] = old
        end
      end

      it { is_expected.to be true }
    end # /context with $poise_debug

    context 'with $poise_debug = false' do
      around do |ex|
        begin
          old = ENV['poise_debug']
          ENV['poise_debug'] = 'false'
          ex.run
        ensure
          ENV['poise_debug'] = old
        end
      end

      it { is_expected.to be false }
    end # /context with $poise_debug = false

    context 'with node["POISE_DEBUG"]' do
      before { default_attributes['POISE_DEBUG'] = true }
      it { is_expected.to be true }
    end # /context with node["POISE_DEBUG"]

    context 'with node["poise_debug"]' do
      before { default_attributes['poise_debug'] = true }
      it { is_expected.to be true }
    end # /context with node["poise_debug"]

    context 'with /POISE_DEBUG' do
      let(:debug_files) { %w{/POISE_DEBUG} }
      it { is_expected.to be true }
    end # /context with /POISE_DEBUG

    context 'with /poise_debug' do
      let(:debug_files) { %w{/poise_debug} }
      it { is_expected.to be true }
    end # /context with /poise_debug

    context 'with a global node' do
      before do
        default_attributes['POISE_DEBUG'] = true
        allow(Chef).to receive(:node).and_return(chef_runner.node)
      end
      subject { described_class.debug? }
      it { is_expected.to be true }
    end # /context with a global node

    context 'with a run_context' do
      before { default_attributes['poise_debug'] = true }
      subject { described_class.debug?(chef_run.run_context) }
      it { is_expected.to be true }
    end # /context with a run_context
  end # /describe .debug?

  describe '.debug' do
    context 'with debugging disabled' do
      before { allow(described_class).to receive(:debug?).and_return(false) }
      it do
        expect(Chef::Log).to_not receive(:debug)
        Poise.debug('msg')
      end
    end # /context with debugging disabled

    context 'with debugging enabled' do
      before { allow(described_class).to receive(:debug?).and_return(true) }
      it do
        expect(Chef::Log).to receive(:debug).with('msg')
        Poise.debug('msg')
      end
    end # /context with debugging enabled
  end # /describe .debug
end
