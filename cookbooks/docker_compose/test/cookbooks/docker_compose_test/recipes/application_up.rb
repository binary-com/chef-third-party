#
# Cookbook Name:: docker_compose_test
# Recipe:: project_up
#
# Copyright (c) 2016 Sebastian Boschert, All Rights Reserved.

cookbook_file '/etc/docker-compose/docker-compose_nginx.yml' do
  action :create
  source 'docker-compose_nginx.yml'
  owner 'root'
  group 'root'
  mode 0640
  notifies :up, 'docker_compose_application[nginx]', :delayed
end

docker_compose_application 'nginx' do
  action :up
  services %w(web_server_1 web_server_2)
  compose_files [ '/etc/docker-compose/docker-compose_nginx.yml' ]
end
