#
# Cookbook:: divelogger-mongo
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

raise 'Only Ubuntu OS supported' if node['platform'] != "ubuntu"

include_recipe 'apt'
include_recipe 'build-essential'
include_recipe 'git'
include_recipe 'mongodb'
include_recipe 'cloudcli'

# Search item from data bags
name = search(:environment, "id:name").first
Chef::Log.info("********** ENVIRONMENT: '#{name}' **********")

if node.attribute?('env')
  Chef::Log.info("********** ENVIRONMENT: '#{node['env']}' **********")
else
  Chef::Log.info("********** ENVIRONMENT: Not found **********")
  raise "Cannot find environment info, aborting.."
end


if node['env'] == 'local'
  credentials = search(:aws, "id:credentials").first
  Chef::Log.info("********** ENVIRONMENT: '#{credentials}' **********")

  cloudcli_aws_s3_file '/home/vagrant/mongo-backup.tar.gz' do
    aws_access_key_id credentials['access_key_id']
    aws_secret_access_key credentials['secret_access_key']
    region 'eu-west-1'
    bucket 'divelogger-backup'
    key 'production/mongo/versioned-backup.tar.gz'
  end

  bash 'restore_mongo' do
    code <<-EOH
    mkdir /home/vagrant/backups
    tar -zxvf /home/vagrant/mongo-backup.tar.gz -C /home/vagrant/backups
    mongorestore /home/vagrant/backups/
    rm -r /home/vagrant/backups
    rm /home/vagrant/mongo-backup.tar.gz
    EOH
  end
elsif node['env'] == 'production'
  bash 'restore_mongo' do
    code <<-EOH
    mkdir /home/ubuntu/backups
    tar -zxvf /home/ubuntu/mongo-backup.tar.gz -C /home/ubuntu/backups
    mongorestore /home/ubuntu/backups/
    EOH
  end
end

# Copy data from s3

#bash 'install_something' do
#  user 'root'
#  cwd '/tmp'
#  code <<-EOH
#  aws s3 cp 
#  tar -zxf tarball.tar.gz
#  cd tarball
#  ./configure
#  make
#  make install
#  EOH
#end
