# # encoding: utf-8

# Inspec test for recipe docker_compose::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

# Ensure the nginx container named web_server_1 is up
describe command('docker ps -q -f name=removeorphans_web_server_1 | wc -l') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "1\n" }
end

# Ensure the nginx container named web_server_2 is down
describe command('docker ps -q -f name=removeorphans_web_server_2 | wc -l') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "0\n" }
end

# Ensure nginx instance web_server_1 is listening on port 8891
describe port(8891) do
  it { should be_listening }
end

# Ensure nginx instance web_server_2 is not listening on port 8892
describe port(8892) do
  it { should_not be_listening }
end
