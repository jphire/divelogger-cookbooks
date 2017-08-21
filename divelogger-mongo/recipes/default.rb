#
# Cookbook:: divelogger-mongo
# Recipe:: default
#
# Copyright:: 2017, Janne Laukkanen, All Rights Reserved.

raise 'Only Ubuntu OS supported' if node['platform'] != "ubuntu"

include_recipe 'apt'
include_recipe 'build-essential'
include_recipe 'sc-mongodb::default'
include_recipe 'cloudcli'

# Search item from data bags
settings = search(:settings, "id:env").first
Chef::Log.info("********** ENVIRONMENT: '#{settings['env']}' **********")

if settings['env']
  Chef::Log.info("********** ENVIRONMENT: '#{settings['env']}' **********")
else
  # Search from aws data bags
  app = search("aws_opsworks_app").first
  settings = app['environment']

  if not settings['env']
    Chef::Log.info("********** ENVIRONMENT: Not found **********")
    raise "Cannot find environment info, aborting.."
  end
end


if ['development', 'test', 'staging'].include? settings['env']

  cloudcli_aws_s3_file "/home/#{settings['username']}/mongo-backup.tar.gz" do
    aws_access_key_id settings['access_key_id']
    aws_secret_access_key settings['secret_access_key']
    region 'eu-west-1'
    bucket 'divelogger-backup'
    key 'production/mongo/versioned-backup.tar.gz'
  end

  bash 'restore_mongo' do
    code <<-EOH
    mkdir /home/#{settings['username']}/backups
    tar -zxvf /home/#{settings['username']}/mongo-backup.tar.gz -C /home/#{settings['username']}/backups
    mongorestore /home/#{settings['username']}/backups/
    rm -r /home/#{settings['username']}/backups
    rm /home/#{settings['username']}/mongo-backup.tar.gz
    EOH
  end
else
  raise "No valid environment specified."
end
