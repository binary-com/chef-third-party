if platform?('amazon')
  default['yum']['erlang_solutions']['baseurl'] = 'https://packages.erlang-solutions.com/rpm/centos/7/$basearch'
  default['yum']['erlang_solutions']['description'] = 'CentOS 7 - $basearch - Erlang Solutions'
else
  default['yum']['erlang_solutions']['baseurl'] = 'https://packages.erlang-solutions.com/rpm/centos/$releasever/$basearch'
  default['yum']['erlang_solutions']['description'] = 'CentOS $releasever - $basearch - Erlang Solutions'
end
default['yum']['erlang_solutions']['gpgkey'] = 'https://packages.erlang-solutions.com/debian/erlang_solutions.asc'
default['yum']['erlang_solutions']['gpgcheck'] = true
default['yum']['erlang_solutions']['enabled'] = true
default['yum']['erlang_solutions']['managed'] = true
