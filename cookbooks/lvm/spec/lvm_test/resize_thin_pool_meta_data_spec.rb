require 'spec_helper'

describe 'test::resize_thin' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: platform, version: version).converge('test::resize_thin_pool_meta_data')
  end

  describe 'on Ubuntu 20.04' do
    let(:platform) { 'ubuntu' }
    let(:version) { '20.04' }

    it 'resizes logical volume' do
      expect(chef_run).to resize_lvm_thin_pool_meta_data('lv-thin_tmeta')
    end
  end

  describe 'on RHEL 7' do
    let(:platform) { 'centos' }
    let(:version) { '7' }

    it 'resizes logical volume' do
      expect(chef_run).to resize_lvm_thin_pool_meta_data('lv-thin_tmeta')
    end
  end

  describe 'on Amazon Linux' do
    let(:platform) { 'amazon' }
    let(:version) { '2' }

    it 'resizes logical volume' do
      expect(chef_run).to resize_lvm_thin_pool_meta_data('lv-thin_tmeta')
    end
  end
end
