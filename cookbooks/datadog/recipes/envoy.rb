# Copyright:: 2011-Present, Datadog
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

include_recipe '::dd-agent'

# Monitor Envoy
#
# Here is the description of acceptable attributes:
# node.datadog.envoy = {
#   # init_config - required: false
#   "init_config" => {
#     # proxy - required: false  - object
#     "proxy" => {
#       "http" => "http://<PROXY_SERVER_FOR_HTTP>:<PORT>",
#       "https" => "https://<PROXY_SERVER_FOR_HTTPS>:<PORT>",
#       "no_proxy" => [
#         "<HOSTNAME_1>",
#         "<HOSTNAME_2>",
#       ],
#     },
#     # skip_proxy - required: false  - boolean
#     "skip_proxy" => false,
#     # timeout - required: false  - number
#     "timeout" => 10,
#     # service - required: false  - string
#     "service" => nil,
#   },
#   # instances - required: false
#   "instances" => [
#     {
#       # stats_url - required: true  - string
#       "stats_url" => "http://localhost:80/stats",
#       # included_metrics - required: false  - array of string
#       "included_metrics" => [
#         "cluster\\.(in|out)\\..*",
#       ],
#       # excluded_metrics - required: false  - array of string
#       "excluded_metrics" => [
#         "^http\\..*",
#       ],
#       # cache_metrics - required: false  - boolean
#       "cache_metrics" => true,
#       # tags - required: false  - array of string
#       "tags" => [
#         "<KEY_1>:<VALUE_1>",
#         "<KEY_2>:<VALUE_2>",
#       ],
#       # service - required: false  - string
#       "service" => nil,
#       # min_collection_interval - required: false  - number
#       "min_collection_interval" => 15,
#       # empty_default_hostname - required: false  - boolean
#       "empty_default_hostname" => false,
#       # proxy - required: false  - object
#       "proxy" => {
#         "http" => "http://<PROXY_SERVER_FOR_HTTP>:<PORT>",
#         "https" => "https://<PROXY_SERVER_FOR_HTTPS>:<PORT>",
#         "no_proxy" => [
#           "<HOSTNAME_1>",
#           "<HOSTNAME_2>",
#         ],
#       },
#       # skip_proxy - required: false  - boolean
#       "skip_proxy" => false,
#       # auth_type - required: false  - string
#       "auth_type" => "basic",
#       # use_legacy_auth_encoding - required: false  - boolean
#       "use_legacy_auth_encoding" => true,
#       # username - required: false  - string
#       "username" => nil,
#       # password - required: false  - string
#       "password" => nil,
#       # ntlm_domain - required: false  - string
#       "ntlm_domain" => "<NTLM_DOMAIN>\\<USERNAME>",
#       # kerberos_auth - required: false  - string
#       "kerberos_auth" => "disabled",
#       # kerberos_cache - required: false  - string
#       "kerberos_cache" => nil,
#       # kerberos_delegate - required: false  - boolean
#       "kerberos_delegate" => false,
#       # kerberos_force_initiate - required: false  - boolean
#       "kerberos_force_initiate" => false,
#       # kerberos_hostname - required: false  - string
#       "kerberos_hostname" => nil,
#       # kerberos_principal - required: false  - string
#       "kerberos_principal" => nil,
#       # kerberos_keytab - required: false  - string
#       "kerberos_keytab" => "<KEYTAB_FILE_PATH>",
#       # aws_region - required: false  - string
#       "aws_region" => nil,
#       # aws_host - required: false  - string
#       "aws_host" => nil,
#       # aws_service - required: false  - string
#       "aws_service" => nil,
#       # tls_verify - required: false  - boolean
#       "tls_verify" => true,
#       # tls_use_host_header - required: false  - boolean
#       "tls_use_host_header" => false,
#       # tls_ignore_warning - required: false  - boolean
#       "tls_ignore_warning" => false,
#       # tls_cert - required: false  - string
#       "tls_cert" => "<CERT_PATH>",
#       # tls_private_key - required: false  - string
#       "tls_private_key" => "<PRIVATE_KEY_PATH>",
#       # tls_ca_cert - required: false  - string
#       "tls_ca_cert" => "<CA_CERT_PATH>",
#       # headers - required: false  - object
#       "headers" => {
#         "Host" => "<ALTERNATIVE_HOSTNAME>",
#         "X-Auth-Token" => "<AUTH_TOKEN>",
#       },
#       # extra_headers - required: false  - object
#       "extra_headers" => {
#         "Host" => "<ALTERNATIVE_HOSTNAME>",
#         "X-Auth-Token" => "<AUTH_TOKEN>",
#       },
#       # timeout - required: false  - number
#       "timeout" => 10,
#       # connect_timeout - required: false  - number
#       "connect_timeout" => nil,
#       # read_timeout - required: false  - number
#       "read_timeout" => nil,
#       # log_requests - required: false  - boolean
#       "log_requests" => false,
#       # persist_connections - required: false  - boolean
#       "persist_connections" => false,
#     },
#   ],
#   # logs - required: false
#   "logs" => nil,
# }

datadog_monitor 'envoy' do
  init_config node['datadog']['envoy']['init_config']
  instances node['datadog']['envoy']['instances']
  logs node['datadog']['envoy']['logs']
  use_integration_template true
  action :add
  notifies :restart, 'service[datadog-agent]' if node['datadog']['agent_start']
end
