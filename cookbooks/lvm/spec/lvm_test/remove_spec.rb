require 'spec_helper'

describe 'test::remove' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: platform, version: version).converge('test::remove')
  end

  before do
    stub_command('/opt/chef/embedded/bin/gem list | grep "chef-ruby-lvm ""').and_return(true)
    stub_command('/opt/chef/embedded/bin/gem list | grep chef-ruby-lvm-attrib').and_return(true)
    allow_any_instance_of(Chef::Recipe).to receive(:shell_out).and_call_original
    pvs = double('pvs', stdout: '1')
    allow_any_instance_of(Chef::Recipe).to receive(:shell_out).with('pvs | grep -c /dev/loop1').and_return(pvs)
    allow(File).to receive(:stat).and_call_original
    allow(File).to receive(:stat).with('/mnt/small').and_return(0100555)
  end

  context 'on Ubuntu 20.04' do
    let(:platform) { 'ubuntu' }
    let(:version) { '20.04' }

    %w(loop10 loop11 loop12 loop13).each do |device|
      it "Create physical volume: #{device}" do
        expect(chef_run).to create_lvm_physical_volume("/dev/#{device}")
      end
    end

    it 'Create volume group' do
      expect(chef_run).to create_lvm_volume_group('vg-rmdata')
    end

    it 'Remove logical volume: rmlogs' do
      expect(chef_run).to remove_lvm_logical_volume('rmlogs')
    end

    it 'Remove logical volume: rmtest' do
      expect(chef_run).to remove_lvm_logical_volume('rmtest')
    end
  end

  context 'on RHEL 7' do
    let(:platform) { 'centos' }
    let(:version) { '7' }

    before(:each) do
      stub_command('/sbin/lvm dumpconfig global/use_lvmetad | grep use_lvmetad=1').and_return(true)
    end

    %w(loop10 loop11 loop12 loop13).each do |device|
      it "Create physical volume: #{device}" do
        expect(chef_run).to create_lvm_physical_volume("/dev/#{device}")
      end
    end

    it 'Create volume group' do
      expect(chef_run).to create_lvm_volume_group('vg-rmdata')
    end

    it 'Remove logical volume: rmlogs' do
      expect(chef_run).to remove_lvm_logical_volume('rmlogs')
    end

    it 'Remove logical volume: rmtest' do
      expect(chef_run).to remove_lvm_logical_volume('rmtest')
    end
  end

  context 'on Amazon Linux' do
    let(:platform) { 'amazon' }
    let(:version) { '2' }

    before(:each) do
      stub_command('/sbin/lvm dumpconfig global/use_lvmetad | grep use_lvmetad=1').and_return(true)
    end

    %w(loop10 loop11 loop12 loop13).each do |device|
      it "Create physical volume: #{device}" do
        expect(chef_run).to create_lvm_physical_volume("/dev/#{device}")
      end
    end

    it 'Create volume group' do
      expect(chef_run).to create_lvm_volume_group('vg-rmdata')
    end

    it 'Remove logical volume: rmlogs' do
      expect(chef_run).to remove_lvm_logical_volume('rmlogs')
    end

    it 'Remove logical volume: rmtest' do
      expect(chef_run).to remove_lvm_logical_volume('rmtest')
    end
  end
end
