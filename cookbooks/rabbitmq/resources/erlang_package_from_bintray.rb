# frozen_string_literal: true
#
# Cookbook Name:: rabbitmq
# Resource:: erlang_package_from_bintray
#
# Copyright 2019, Pivotal Software, Inc.
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

actions :install, :remove
default_action :install

attribute :version, String
attribute :use_hipe, [TrueClass, FalseClass], default: false
attribute :options, [String, Array]
attribute :retries, Integer, default: 3
attribute :retry_delay, Integer, default: 10
