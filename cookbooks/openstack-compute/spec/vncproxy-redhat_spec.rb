require_relative 'spec_helper'

describe 'openstack-compute::vncproxy' do
  ALL_RHEL.each do |p|
    context "redhat #{p[:version]}" do
      let(:runner) { ChefSpec::SoloRunner.new(p) }
      let(:node) { runner.node }
      cached(:chef_run) { runner.converge(described_recipe) }

      include_context 'compute_stubs'
      include_examples 'expect_runs_nova_common_recipe'
      include_examples 'expect_creates_nova_state_dir'
      include_examples 'expect_creates_nova_lock_dir'

      it 'upgrades nova vncproxy package' do
        expect(chef_run).to upgrade_package('openstack-nova-novncproxy')
      end

      it 'starts nova vncproxy' do
        expect(chef_run).to start_service('openstack-nova-novncproxy')
      end

      it 'starts nova vncproxy on boot' do
        expect(chef_run).to enable_service('openstack-nova-novncproxy')
      end
    end
  end
end
