if os[:name] == 'amazon'
  describe command('/usr/bin/docker --version') do
    its(:exit_status) { should eq 0 }
  end
else
  describe command('/usr/bin/docker --version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/19\.03\./) }
  end
end
