# frozen_string_literal: true
#
# Cookbook Name:: rabbitmq
# Resource:: erlang_apt_repository_on_cloudsmith
#
# Copyright 2019-2021, VMware, Inc. or its affiliates
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

<<<<<<< HEAD:cookbooks/rabbitmq/resources/erlang_apt_repository_on_bintray.rb
unified_mode true
=======
unified_mode true if respond_to?(:unified_mode)
>>>>>>> 78423de9c1a225a6f6fdfb60876e9c8cfeb2aafe:cookbooks/rabbitmq/resources/erlang_apt_repository_on_cloudsmith.rb

actions :add, :remove
default_action :add

attribute :uri, String, default: ''
attribute :distribution, String
attribute :components, Array, default: ['erlang']
attribute :key, String, default: ''
attribute :keyserver, String

attribute :trusted, [true, false], default: false
