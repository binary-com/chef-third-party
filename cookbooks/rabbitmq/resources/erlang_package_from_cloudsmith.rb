# frozen_string_literal: true
#
# Cookbook Name:: rabbitmq
# Resource:: erlang_package_from_cloudsmith
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

unified_mode true if respond_to?(:unified_mode)

actions :install, :remove
default_action :install

attribute :version, String
# HiPE's been deprecated since Erlang/OTP 22 and is going away in Erlang/OTP 24.
# DO NOT USE.
attribute :use_hipe, [true, false], default: false
attribute :options, [String, Array]
attribute :retries, Integer, default: 3
attribute :retry_delay, Integer, default: 10
