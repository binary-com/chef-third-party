require_relative 'spec_helper'

describe 'openstack-compute::serialproxy' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }

    include_context 'compute_stubs'
    include_examples 'expect_runs_nova_common_recipe'
    include_examples 'expect_creates_nova_state_dir'
    include_examples 'expect_creates_nova_lock_dir'

    it 'upgrades nova serialproxy package' do
      expect(chef_run).to upgrade_package('openstack-nova-serialproxy')
    end

    it 'starts nova serialproxy' do
      expect(chef_run).to start_service('openstack-nova-serialproxy')
    end

    it 'starts nova serialproxy on boot' do
      expect(chef_run).to enable_service('openstack-nova-serialproxy')
    end
  end
end
