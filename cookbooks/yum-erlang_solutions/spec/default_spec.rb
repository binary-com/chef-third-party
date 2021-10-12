require 'spec_helper'

describe 'yum-erlang_solutions::default' do
  context 'centos-7' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7'
      ).converge(described_recipe)
    end

    it 'renders the yum repository with defaults' do
      expect(chef_run).to create_yum_repository('erlang_solutions').with(
        repositoryid: 'erlang_solutions',
        baseurl: 'https://packages.erlang-solutions.com/rpm/centos/$releasever/$basearch'
      )
    end
  end
end
