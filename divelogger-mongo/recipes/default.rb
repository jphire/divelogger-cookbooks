#
# Cookbook:: divelogger-mongo
# Recipe:: default
#
# Copyright:: 2017, Janne Laukkanen, All Rights Reserved.

raise 'Only Ubuntu OS supported' if node['platform'] != 'ubuntu'

include_recipe 'apt'
include_recipe 'build-essential'
include_recipe 'sc-mongodb::default'
include_recipe 'cloudcli'

settings = node.default['divelogger']['settings']

if node['env'] == 'development'
  # Get credentials from local data bags
  credentials = search(:settings, 'id:env').first
  settings['access_key_id'] = credentials['access_key_id']
  settings['secret_access_key'] = credentials['secret_access_key']
  Chef::Log.info("********** ENVIRONMENT: '#{node['env']}' **********")
elsif ['test', 'staging', 'production'].include? node['env']
  # Search credentials from aws data bags
  stack = search(:aws_opsworks_stack).first
  settings['access_key_id'] = stack['custom_cookbooks_source']['username']
  settings['secret_access_key'] = stack['custom_cookbooks_source']['password']
end

if ['development', 'test', 'staging'].include? node['env']

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
  raise 'No valid environment specified.'
end
