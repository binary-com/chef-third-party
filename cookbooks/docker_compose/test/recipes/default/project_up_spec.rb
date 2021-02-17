# # encoding: utf-8

# Inspec test for recipe docker_compose::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

# Ensure the correct image was pulled
describe command('docker ps -f name=nginx_web_server_1 | awk \'BEGIN{FS="  +"} NR > 1 { print $2 }\'') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "nginx\n" }
end

# Ensure the first specified nginx container is up
describe command('docker ps -q -f name=nginx_web_server_1 | wc -l') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "1\n" }
end

# Ensure the second specified nginx container is up
describe command('docker ps -q -f name=nginx_web_server_2 | wc -l') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "1\n" }
end

# Ensure the third specified nginx container is not up
describe command('docker ps -q -f name=nginx_web_server_3 | wc -l') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should eq "0\n" }
end

# Ensure the first specified nginx instance is listening on port 8001
describe port(8001) do
  it { should be_listening }
end

# Ensure the second specified nginx instance is listening on port 8002
describe port(8002) do
  it { should be_listening }
end

# Ensure the second specified nginx instance is listening on port 8003
describe port(8003) do
  it { should_not be_listening }
end
