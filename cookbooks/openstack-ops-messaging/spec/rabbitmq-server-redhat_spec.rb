require_relative 'spec_helper'

describe 'openstack-ops-messaging::rabbitmq-server' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }

    include_context 'ops_messaging_stubs'

    it 'does not set use_distro_version to true' do
      expect(chef_run.node['rabbitmq']['use_distro_version']).to be_truthy
    end
  end
end
