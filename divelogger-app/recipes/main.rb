extend Helper::Utils

def_settings = node.default['divelogger']['settings']

valid_envs = ['development', 'staging', 'test', 'production']

if valid_envs.include? node['env']
  Chef::Log.info("********** ENVIRONMENT: '#{node}' **********")
else
  raise 'No valid environment specified'
end

settings = Helper::Utils.get_settings(node['env'], def_settings)

ENV['NODE_ENV'] = node['env']

# Create app user
user 'www' do
  system true
  shell '/bin/false'
end

# Fetch application code bundle
cloudcli_aws_s3_file '/srv/www/divelogger.zip' do
  aws_access_key_id settings['access_key_id']
  aws_secret_access_key settings['secret_access_key']
  region settings['region']
  bucket 'divelogger-code'
  key 'dist/divelogger.zip'
end

# Install application
bash 'setup-server' do
  cwd '/srv/www'
  user 'root'
  code <<-EOH
    unzip divelogger.zip -d divelogger
    cd divelogger
    mkdir log
    npm install
    cd ..
    chown -R www:www divelogger/
  EOH
end

# Configure start script for application
bash 'setup-node' do
  cwd '/srv/www'
  user 'www'
  code <<-EOH
    cd divelogger
    touch .env
    echo "NODE_ENV=#{node['env']}" >>.env
    echo "NODE_PORT=#{settings['port']}" >>.env
    echo "NODE_HTTPS=#{settings['https']}" >>.env
    echo "mongo_host=#{settings['mongo_host']}" >>.env
    echo "secretToken=#{settings['secretToken']}" >>.env
    touch start.sh
    echo "#!/bin/bash" >start.sh
    echo "cd /srv/www/divelogger ; source /srv/www/divelogger/.env ; /usr/bin/env PORT=#{settings['port']} NODE_PATH=/srv/www/divelogger/node_modules:/srv/www/divelogger /usr/local/bin/node /srv/www/divelogger/server.js 2>>/srv/www/divelogger/log/node.stderr.log 1>>/srv/www/divelogger/log/node.stdout.log" >>start.sh
    chmod +x start.sh
  EOH
end

# Install monit and start application
include_recipe 'monit-ng'

monit_check 'divelogger' do
  check_type 'host'
  check_id '127.0.0.1'
  start_as 'www'
  start_as_group 'www'
  start '/srv/www/divelogger/start.sh'
  stop_as 'www'
  stop_as_group 'www'
  stop "/usr/bin/pkill -f 'node /srv/www/divelogger/server.js'"
  tests [
      {
          'condition' => 'failed port 3001 protocol HTTP request / with timeout 10 seconds',
          'action'    => 'restart'
      }
  ]
end

# Configure log rotation
logrotate_app 'node-divelogger' do
  path      ['/srv/www/divelogger/log/node.stderr.log', '/srv/www/divelogger/log/node.stdout.log']
  options   ['missingok', 'delaycompress', 'notifempty', 'sharedscripts']
  frequency 'daily'
  rotate    30
  create    '644 root adm'
end

# Install certs only in production!
# include_recipe "#{cookbook_name}::certbot"

# Redis monit configuration
# monit_check 'redis' do
#   check_id  '/var/run/redis/redis-server.pid'
#   group     'database'
#   start     '/etc/init.d/redis-server start'
#   stop      '/etc/init.d/redis-server stop'
#   tests [
#             {
#                 'condition' => 'failed host 127.0.0.1 port 6379
#                    send "SET MONIT-TEST value\r\n" expect "OK"
#                    send "EXISTS MONIT-TEST\r\n" expect ":1"',
#                 'action'    => 'restart'
#             },
#             {
#                 'condition' => '3 restarts within 5 cycles',
#                 'action'    => 'alert'
#             },
#         ]
# end