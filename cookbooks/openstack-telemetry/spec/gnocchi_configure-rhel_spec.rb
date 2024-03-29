require_relative 'spec_helper'

describe 'openstack-telemetry::gnocchi_configure' do
  ALL_RHEL.each do |p|
    context "redhat #{p[:version]}" do
      let(:runner) { ChefSpec::SoloRunner.new(p) }
      let(:node) { runner.node }
      cached(:chef_run) { runner.converge(described_recipe) }

      include_context 'telemetry-stubs'

      it do
        expect(chef_run).to_not create_cookbook_file('/etc/ceilometer/gnocchi_resources.yaml')
          .with(
            source: 'gnocchi_resources.yaml',
            owner: 'ceilometer',
            group: 'ceilometer',
            mode: '640'
          )
      end
    end
  end
end
