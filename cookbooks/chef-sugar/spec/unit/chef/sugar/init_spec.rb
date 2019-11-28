require 'spec_helper'

describe Chef::Sugar::Init do
  it_behaves_like 'a chef sugar'

  before(:each) do
    allow(IO).to receive(:read)
      .with("/proc/1/comm")
      .and_return("init")
    allow(File).to receive(:executable?)
      .with("/sbin/initctl")
      .and_return(false)
    allow(File).to receive(:executable?)
      .with("/sbin/runit-init")
      .and_return(false)
  end

  describe '#systemd?' do
    systemctl_path = '/bin/systemctl'
    it "is true when #{systemctl_path} exists" do
      allow(File).to receive(:exist?)
        .with(systemctl_path)
        .and_return(true)

      node = {}
      expect(described_class.systemd?(node)).to be true
    end

    it "is false when #{systemctl_path} does not exist" do
      allow(File).to receive(:exist?)
        .with(systemctl_path)
        .and_return(false)

      node = {}
      expect(described_class.systemd?(node)).to be false
    end
  end

  describe '#upstart?' do
    it 'is true when /sbin/initctl is executable' do
      allow(File).to receive(:executable?)
        .with("/sbin/initctl")
        .and_return(true)

      node = {}
      expect(described_class.upstart?(node)).to be true
    end

    it 'is false when /sbin/initctl is not executable' do
      node = {}
      expect(described_class.upstart?(node)).to be false
    end
  end

  describe '#runit?' do
    it 'is true when /sbin/runit-init is executable' do
      allow(File).to receive(:executable?)
        .with("/sbin/runit-init")
        .and_return(true)

      node = {}
      expect(described_class.runit?(node)).to be true
    end

    it 'is false when /sbin/runit-init is not executable' do
      node = {}
      expect(described_class.runit?(node)).to be false
    end
  end
end
