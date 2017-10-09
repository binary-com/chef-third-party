#
# Author:: Noah Kantrowitz <noah@opscode.com>
# Cookbook Name:: supervisor
# Resource:: service
#
# Copyright:: 2011, Opscode, Inc <legal@opscode.com>
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

# property :name, name_property: true, kind_of: String, required: true, :name_property => true
# property :service_name, :kind_of => String
property :service_name, kind_of: String, name_property: true
property :command, kind_of: String
property :process_name, kind_of: String, default: '%(program_name)s'
property :numprocs, kind_of: Integer, default: 1
property :numprocs_start, kind_of: Integer, default: 0
property :priority, kind_of: Integer, default: 999
property :autostart, kind_of: [TrueClass, FalseClass], default: true
property :autorestart, kind_of: [String, Symbol, TrueClass, FalseClass], default: :unexpected
property :startsecs, kind_of: Integer, default: 1
property :startretries, kind_of: Integer, default: 3
property :exitcodes, kind_of: Array, default: [0, 2]
property :stopsignal, kind_of: [String, Symbol], default: :TERM
property :stopwaitsecs, kind_of: Integer, default: 10
property :stopasgroup, kind_of: [TrueClass, FalseClass], default: nil
property :killasgroup, kind_of: [TrueClass, FalseClass], default: nil
property :user, kind_of: [String, NilClass], default: nil
property :redirect_stderr, kind_of: [TrueClass, FalseClass], default: false
property :stdout_logfile, kind_of: String, default: 'AUTO'
property :stdout_logfile_maxbytes, kind_of: String, default: '50MB'
property :stdout_logfile_backups, kind_of: Integer, default: 10
property :stdout_capture_maxbytes, kind_of: String, default: '0'
property :stdout_events_enabled, kind_of: [TrueClass, FalseClass], default: false
property :stderr_logfile, kind_of: String, default: 'AUTO'
property :stderr_logfile_maxbytes, kind_of: String, default: '50MB'
property :stderr_logfile_backups, kind_of: Integer, default: 10
property :stderr_capture_maxbytes, kind_of: String, default: '0'
property :stderr_events_enabled, kind_of: [TrueClass, FalseClass], default: false
property :environment, kind_of: Hash, default: {}
property :directory, kind_of: [String, NilClass], default: nil
property :umask, kind_of: [NilClass, String], default: nil
property :serverurl, kind_of: String, default: 'AUTO'

property :eventlistener, kind_of: [TrueClass, FalseClass], default: false
property :eventlistener_buffer_size, kind_of: Integer, default: nil
property :eventlistener_events, kind_of: Array, default: nil

attr_accessor :state
attr_accessor :exists

def load_current_value
  state = get_current_state(name)
end

action :enable do
  converge_by("Enabling #{new_resource}") do
    enable_service
  end
end

action :disable do
  if state == 'UNAVAILABLE'
    Chef::Log.info "#{new_resource} is already disabled."
  else
    converge_by("Disabling #{new_resource}") do
      disable_service
    end
  end
end

action :start do
  case state
  when 'UNAVAILABLE'
    raise "Supervisor service #{name} cannot be started because it does not exist"
  when 'RUNNING'
    Chef::Log.debug "#{new_resource} is already started."
  when 'STARTING'
    Chef::Log.debug "#{new_resource} is already starting."
    wait_til_state('RUNNING')
  else
    converge_by("Starting #{new_resource}") do
      unless supervisorctl('start')
        raise "Supervisor service #{name} was unable to be started"
      end
    end
  end
end

action :stop do
  case state
  when 'UNAVAILABLE'
    raise "Supervisor service #{name} cannot be stopped because it does not exist"
  when 'STOPPED'
    Chef::Log.debug "#{new_resource} is already stopped."
  when 'STOPPING'
    Chef::Log.debug "#{new_resource} is already stopping."
    wait_til_state('STOPPED')
  else
    converge_by("Stopping #{new_resource}") do
      unless supervisorctl('stop')
        raise "Supervisor service #{name} was unable to be stopped"
      end
    end
  end
end

action :restart do
  case state
  when 'UNAVAILABLE'
    raise "Supervisor service #{name} cannot be restarted because it does not exist"
  else
    converge_by("Restarting #{new_resource}") do
      unless supervisorctl('restart')
        raise "Supervisor service #{name} was unable to be started"
      end
    end
  end
end

action_class.class_eval do
  def enable_service
    e = execute 'supervisorctl update' do
      action :nothing
      user 'root'
    end

    t = template "#{node['supervisor']['dir']}/#{service_name}.conf" do
      source 'program.conf.erb'
      cookbook 'supervisor'
      owner 'root'
      group 'root'
      mode '644'
      variables prog: new_resource
      notifies :run, 'execute[supervisorctl update]', :immediately
    end

    t.run_action(:create)
    e.run_action(:run) if t.updated?
  end

  def disable_service
    execute 'supervisorctl update' do
      action :nothing
      user 'root'
    end

    file "#{node['supervisor']['dir']}/#{service_name}.conf" do
      action :delete
      notifies :run, 'execute[supervisorctl update]', :immediately
      only_if { ::File.exist?("#{node['supervisor']['dir']}/#{service_name}.conf") }
    end
  end

  def supervisorctl(action)
    cmd = "supervisorctl #{action} #{cmd_line_args} | grep -v ERROR"
    result = Mixlib::ShellOut.new(cmd).run_command
    # Since we append grep to the command
    # The command will have an exit code of 1 upon failure
    # So 0 here means it was successful
    result.exitstatus == 0
  end

  def cmd_line_args
    name = service_name
    name += ':*' if process_name != '%(program_name)s'
    name
  end

  def get_current_state(service_name)
    result = Mixlib::ShellOut.new('supervisorctl status').run_command
    match = result.stdout.match("(^#{service_name}(\\:\\S+)?\\s*)([A-Z]+)(.+)")
    if match.nil?
      'UNAVAILABLE'
    else
      match[3]
    end
  end

  def wait_til_state(state, max_tries = 20)
    service = service_name

    max_tries.times do
      return if get_current_state(service) == state

      Chef::Log.debug("Waiting for service #{service} to be in state #{state}")
      sleep 1
    end

    raise "service #{service} not in state #{state} after #{max_tries} tries"
  end
end
