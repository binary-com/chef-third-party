require 'spec_helper'
require_relative '../../libraries/helpers_service'

describe 'docker_test::service' do
  before do
    allow_any_instance_of(DockerCookbook::DockerHelpers::Service).to receive(:installed_docker_version).and_return('19.03.5')
  end

  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu',
                             version: '16.04',
                             step_into: %w(helpers_service docker_service docker_service_base docker_service_manager docker_service_manager_systemd)).converge(described_recipe)
  end

  # If you have to change this file you most likely updated a default service option
  # Please note that it will require a docker service restart
  # Which is consumer impacting
  expected = <<EOH
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
BindsTo=containerd.service
After=network-online.target docker.socket firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
ExecStartPre=/sbin/sysctl -w net.ipv4.ip_forward=1
ExecStartPre=/sbin/sysctl -w net.ipv6.conf.all.forwarding=1
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd  --bip=10.10.10.0/24 --group=docker --default-address-pool=base=10.10.10.0/16,size=24 --pidfile=/var/run/docker.pid --storage-driver=overlay2 --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target


EOH

  it 'creates docker_service[default]' do
    expect(chef_run).to render_file('/etc/systemd/system/docker.service').with_content { |content|
      # For tests which run on windows - convert CRLF
      expect(content.gsub(/[\r\n]+/m, "\n")).to match(expected.gsub(/[\r\n]+/m, "\n"))
    }
  end
end
