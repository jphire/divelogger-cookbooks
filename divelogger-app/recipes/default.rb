#
# Cookbook:: divelogger-app
# Recipe:: default
#
# Copyright:: 2017, Janne Laukkanen, All Rights Reserved.
raise 'Only Ubuntu OS supported' if node['platform'] != "ubuntu"

include_recipe 'apt'

# Install nodejs
include_recipe "#{cookbook_name}::nodejs"

# Install redis
include_recipe "#{cookbook_name}::redis"

# Install utils
include_recipe 'cloudcli'
include_recipe 'logrotate'

apt_package 'unzip' do
  action :install
end

include_recipe "#{cookbook_name}::main"

