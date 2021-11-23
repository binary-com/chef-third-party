# Debian 9 does not include 20.10
if os.name == 'debian' && os.release.to_i == 9
  describe command('/usr/bin/docker --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/19\.03\./) }
  end
else
  describe command('/usr/bin/docker --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/20\.10\./) }
  end
end

# NOTE: See https://github.com/sous-chefs/docker/pull/1194
describe service('docker.service') do
  it { should be_installed }
  it { should_not be_running }
  it { should_not be_enabled }
end

describe service('docker.socket') do
  it { should be_installed }
  it { should_not be_running }
  it { should_not be_enabled }
end
