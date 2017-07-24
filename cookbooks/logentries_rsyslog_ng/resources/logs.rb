#
# Cookbook Name:: logentries_rsyslog_ng
# Resource:: logs
#
# Author: Kostiantyn Lysenko gshaud@gmail.com
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

actions :add, :remove

default_action :add

attribute :log_filename, :kind_of => String, :name_attribute => true, :required => true
attribute :log_owner, :kind_of => [String], :default => 'root'
attribute :log_group, :kind_of => [String], :default => 'root'
attribute :rsyslog_conf, :kind_of => String, :required => true
attribute :logentries_logset, :kind_of => String, :required => true
attribute :logentries_name, :kind_of => String, :required => true
attribute :logentries_account_key, :kind_of => String, :required => true
attribute :logentries_host_key, :kind_of => String, :required => false
attribute :logentries_log_token, :kind_of => String, :required => false
attribute :syslog_facility, :kind_of => [String, NilClass], :default => nil
attribute :rsyslog_tls_enable, :kind_of => [TrueClass, FalseClass], :default => true
attribute :rsyslog_ruleset, :kind_of => [String, NilClass], :default => nil
attribute :rsyslog_selector, :kind_of => [String], :default => '*.*'
attribute :rsyslog_tag, :kind_of => [String, NilClass], :default => nil
attribute :rsyslog_imfile_module, :kind_of => [TrueClass, FalseClass], :default => true
attribute :cookbook, :kind_of => [String], :default => 'logentries_rsyslog_ng'
attribute :logentries_source, :kind_of => [String], :default => 'rsyslog_logentries.conf.erb'
attribute :imfile_module_source, :kind_of => [String], :default => 'modules_imfile.conf.erb'
attribute :node_identity, :kind_of => String, :default => node[:hostname]
