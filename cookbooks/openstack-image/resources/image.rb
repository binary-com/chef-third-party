#
# Cookbook:: openstack-image
# Resource:: image
#
# Copyright:: 2012-2021, Rackspace US, Inc.
# Copyright:: 2020-2021, Oregon State University
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

actions :upload
default_action :upload
unified_mode true

BOOLEAN = [TrueClass, FalseClass].freeze

attribute :image_url, kind_of: String
attribute :image_type, kind_of: String, default: 'unknown', equal_to: %w(unknown ami qcow vhd vmdk vdi iso raw)
attribute :image_name, kind_of: String, default: 'default'
attribute :image_public, kind_of: BOOLEAN, default: true
attribute :image_id, kind_of: String, default: ''
attribute :identity_user, kind_of: String
attribute :identity_pass, kind_of: String
attribute :identity_tenant, kind_of: String
attribute :identity_uri, kind_of: String
attribute :identity_user_domain_name, kind_of: String
attribute :identity_project_domain_name, kind_of: String
