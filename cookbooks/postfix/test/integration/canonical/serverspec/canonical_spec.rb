# Copyright:: 2012-2017, Chef Software, Inc.
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
require_relative './spec_helper'

describe file('/etc/postfix/recipient_canonical.db') do
  it { should be_file }
end

describe file('/etc/postfix/main.cf') do
  its(:content) { should match(%r{^\s*recipient_canonical_maps\s*=.*\/etc\/postfix\/recipient_canonical\s*$}) }
end
