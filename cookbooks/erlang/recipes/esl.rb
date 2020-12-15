#
# Cookbook:: erlang
# Recipe:: esl
#
# Author:: Christopher Maier (<cm@chef.io>)
# Copyright:: 2013-2019, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Install Erlang/OTP from Erlang Solutions

case node['platform_family']
when 'debian'
  package 'apt-transport-https'

  apt_repository 'erlang_solutions_repo' do
    uri node['erlang']['esl']['repo']['uri']
    distribution node['erlang']['esl']['lsb_codename']
    components ['contrib']
    key node['erlang']['esl']['repo']['key']
    action :add
  end

  apt_preference 'erlang_solutions_repo' do
    package_name 'esl-erlang'
    pin "version #{node['erlang']['esl']['version']}"
    pin_priority '700'
    action :add
    not_if { node['erlang']['esl']['version'].nil? }
  end

  package 'esl-erlang' do
    version node['erlang']['esl']['version'] if node['erlang']['esl']['version']
  end
when 'rhel'
  include_recipe 'yum-erlang_solutions'

  package 'esl-erlang' do
    version node['erlang']['esl']['version'] if node['erlang']['esl']['version']
  end
end
