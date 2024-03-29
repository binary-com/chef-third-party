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

require 'chefspec'
require_relative '../../libraries/test_helpers'

describe 'datadog_integration' do
  step_into :datadog_integration
  platform 'ubuntu'
  default_attributes['datadog']['agent_major_version'] = 7

  context 'with datadog integration' do
    stubs_for_resource('execute[integration install]') do |resource|
      allow(resource).to receive_shell_out('/opt/datadog-agent/bin/agent/agent integration show -q datadog-foobar')
    end
    recipe do
      datadog_integration 'datadog-foobar' do
        version '1.0.0'
      end
    end
    it { is_expected.to run_execute('integration install').with(command: '"/opt/datadog-agent/bin/agent/agent" integration install datadog-foobar==1.0.0') }
  end

  context 'with third party integration that is not installed' do
    stubs_for_resource('execute[integration install]') do |resource|
      allow(resource).to receive_shell_out('/opt/datadog-agent/bin/agent/agent integration show -q foo-bar')
    end
    recipe do
      datadog_integration 'foo-bar' do
        version '1.0.0'
        third_party true
      end
    end
    it { is_expected.to run_execute('integration install').with(command: '"/opt/datadog-agent/bin/agent/agent" integration install --third-party foo-bar==1.0.0') }
  end

  context 'with third party integration that is already installed' do
    stubs_for_resource('execute[integration install]') do |resource|
      allow(resource).to receive_shell_out('/opt/datadog-agent/bin/agent/agent integration show -q foo-bar')
        .and_return(Mock::ShellCommandResult.new('1.0.0'))
    end
    recipe do
      datadog_integration 'foo-bar' do
        version '1.0.0'
        third_party true
      end
    end
    it { is_expected.not_to run_execute('integration install') }
  end

  context 'with third party integration that is installed with an older version' do
    stubs_for_resource('execute[integration install]') do |resource|
      allow(resource).to receive_shell_out('/opt/datadog-agent/bin/agent/agent integration show -q foo-bar')
        .and_return(Mock::ShellCommandResult.new('0.9.0'))
    end
    recipe do
      datadog_integration 'foo-bar' do
        version '1.0.0'
        third_party true
      end
    end
    it { is_expected.to run_execute('integration install').with(command: '"/opt/datadog-agent/bin/agent/agent" integration install --third-party foo-bar==1.0.0') }
  end
end
