os_release = os.name == 'amazon' ? '7' : os.release.to_i

describe yum.repo 'erlang_solutions' do
  it { should exist }
  it { should be_enabled }
  its('baseurl') { "https://packages.erlang-solutions.com/rpm/centos/#{os_release}/x86_64/" }
end

describe command "erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell" do
  its('exit_status') { should eq 0 }
end
