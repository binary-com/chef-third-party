#
# Cookbook Name:: logentries_rsyslog_ng
# Library:: logentries
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

require 'json'
require 'open-uri'
require 'net/http'
require 'net/https'

module Logentries

  LURL = "http://api.logentries.com/"
  
  def self.get_response(url)
    uri = URI(URI.escape(url))
    response = Net::HTTP.get_response(uri)

    response
  end

  def self.get_host_key(account_key, logentries_logset)
    url = LURL + account_key + '/hosts/' + logentries_logset

    response = get_response(url)
    logset = JSON.parse(response.body)
    
    hostkey = ''
    hostkey = logset['key']

    hostkey
  end

  def self.get_logs(account_key, host_key)
    url = LURL + account_key + '/hosts/' + host_key + '/'
    response = get_response(url)

    logs = JSON.parse(response.body)

    logs['list']
  end

  def self.get_log(account_key, host_key, log_name)
    logs = get_logs(account_key, host_key)

    log = nil
    
    logs.each do |l|
      if l['name'] == log_name
        log = l
        break
      end
    end

    log
  end

  def self.get_log_token(account_key, host_key, log_name)
    log = get_log(account_key, host_key, log_name)

    log['token']
  end
  
  def self.log_exist?(account_key, host_key, log_name)
    log = get_log(account_key, host_key, log_name)

    log ? true : false
  end

  def self.add_log(account_key,host_key,log_name)
    if log_exist?(account_key,host_key,log_name)
      return get_log_token(account_key,host_key,log_name)
    end
    params = {
      'request' => 'new_log',
      'user_key' => account_key,
      'host_key' => host_key,
      'name' => log_name,
      'type' => '',
      'filename' => '',
      'retention' => '-1',
      'source' => 'token'
    }

    uri = URI.parse(LURL)
    http = Net::HTTP.new(uri.host,uri.port)
    req = Net::HTTP::Post.new(uri.path)

    req.set_form_data(params)
    raw_response = http.request(req)

    response = JSON.parse(raw_response.body)
    response['log']['token']
  end

  def self.remove_log
  end

end
