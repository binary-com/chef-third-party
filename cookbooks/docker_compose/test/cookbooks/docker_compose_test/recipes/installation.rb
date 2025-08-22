#
# Cookbook Name:: docker_compose_test
# Recipe:: installation
#
# Copyright (c) 2016 Sebastian Boschert, All Rights Reserved.

docker_service 'default' do
 action [:create, :start]
end

include_recipe 'docker_compose::installation'
