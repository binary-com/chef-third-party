require_relative 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', 'libraries', 'search'

describe 'openstack-common::default' do
  describe 'Openstack Search' do
    let(:runner) { ChefSpec::SoloRunner.new(CHEFSPEC_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) do
      node.override['openstack']['mq']['server_role'] = 'openstack-ops-mq'
      node.override['openstack']['endpoints']['mq']['port'] = 5672
      # speed up tests
      node.override['openstack']['common']['search_count_max'] = 2
      runner.converge(described_recipe)
    end
    cached(:subject) { Object.new.extend(Openstack) }

    describe '#search_for' do
      it 'returns results' do
        allow(subject).to receive(:node).and_return(chef_run.node)
        allow(subject).to receive(:search)
          .with(:node, '(chef_environment:_default AND roles:role) OR (chef_environment:_default AND recipes:role)')
          .and_return([chef_run.node])
        resp = subject.search_for('role')
        expect(resp[0]['fqdn']).to eq('fauxhai.local')
      end

      it 'returns empty results' do
        allow(subject).to receive(:node).and_return(chef_run.node)
        allow(subject).to receive(:search)
          .with(:node, '(chef_environment:_default AND roles:empty-role) OR (chef_environment:_default AND recipes:empty-role)')
          .and_return([])
        expect(
          subject.search_for('empty-role')
        ).to eq([])
      end

      it 'always returns empty results' do
        allow(subject).to receive(:node).and_return(chef_run.node)
        allow(subject).to receive(:search)
          .with(:node, '(chef_environment:_default AND roles:empty-role) OR (chef_environment:_default AND recipes:empty-role)')
          .and_return(nil)
        expect(
          subject.search_for('empty-role')
        ).to eq([])
      end
    end

    describe '#memcached_servers' do
      it 'returns memcached list' do
        nodes = [
          { 'memcached' => { 'listen' => '1.1.1.1', 'port' => '11211' } },
          { 'memcached' => { 'listen' => '2.2.2.2', 'port' => '11211' } },
        ]
        allow(subject).to receive(:node).and_return(chef_run.node)
        allow(subject).to receive(:search_for)
          .with('role')
          .and_return(nodes)
        expect(
          subject.memcached_servers('role')
        ).to eq(['1.1.1.1:11211', '2.2.2.2:11211'])
      end

      it 'returns sorted memcached list' do
        nodes = [
          { 'memcached' => { 'listen' => '3.3.3.3', 'port' => '11211' } },
          { 'memcached' => { 'listen' => '1.1.1.1', 'port' => '11211' } },
          { 'memcached' => { 'listen' => '2.2.2.2', 'port' => '11211' } },
        ]
        allow(subject).to receive(:node).and_return(chef_run.node)
        allow(subject).to receive(:search_for)
          .with('role')
          .and_return(nodes)
        expect(
          subject.memcached_servers('role')
        ).to eq(['1.1.1.1:11211', '2.2.2.2:11211', '3.3.3.3:11211'])
      end

      it 'returns memcached servers as defined by attributes' do
        nodes = {
          'openstack' => {
            'memcached_servers' => ['1.1.1.1:11211', '2.2.2.2:11211'],
          },
        }
        allow(subject).to receive(:node).and_return(chef_run.node.merge(nodes))
        expect(
          subject.memcached_servers('role')
        ).to eq(['1.1.1.1:11211', '2.2.2.2:11211'])
      end

      it 'returns empty memcached servers as defined by attributes' do
        nodes = {
          'openstack' => {
            'memcached_servers' => [],
          },
        }
        allow(subject).to receive(:node).and_return(chef_run.node.merge(nodes))
        expect(
          subject.memcached_servers('empty-role')
        ).to eq([])
      end
    end

    describe '#rabbit_servers' do
      it 'returns rabbit servers' do
        nodes = [
          { 'openstack' => { 'mq' => { 'listen' => '1.1.1.1' }, 'endpoints' => { 'mq' => { 'port' => '5672' } } } },
          { 'openstack' => { 'mq' => { 'listen' => '2.2.2.2' }, 'endpoints' => { 'mq' => { 'port' => '5672' } } } },
        ]
        allow(subject).to receive(:node).and_return(chef_run.node)
        allow(subject).to receive(:search_for)
          .and_return(nodes)
        expect(
          subject.rabbit_servers
        ).to eq('1.1.1.1:5672,2.2.2.2:5672')
      end

      it 'returns sorted rabbit servers' do
        nodes = [
          { 'openstack' => { 'mq' => { 'listen' => '3.3.3.3' }, 'endpoints' => { 'mq' => { 'port' => '5672' } } } },
          { 'openstack' => { 'mq' => { 'listen' => '1.1.1.1' }, 'endpoints' => { 'mq' => { 'port' => '5672' } } } },
          { 'openstack' => { 'mq' => { 'listen' => '2.2.2.2' }, 'endpoints' => { 'mq' => { 'port' => '5672' } } } },
        ]
        allow(subject).to receive(:node).and_return(chef_run.node)
        allow(subject).to receive(:search_for)
          .and_return(nodes)
        expect(
          subject.rabbit_servers
        ).to eq('1.1.1.1:5672,2.2.2.2:5672,3.3.3.3:5672')
      end

      it 'returns rabbit servers when not searching' do
        chef_run.node.override['openstack']['mq']['servers'] = ['1.1.1.1', '2.2.2.2']
        allow(subject).to receive(:node).and_return(chef_run.node)
        expect(
          subject.rabbit_servers
        ).to eq('1.1.1.1:5672,2.2.2.2:5672')
      end
    end
  end
end
