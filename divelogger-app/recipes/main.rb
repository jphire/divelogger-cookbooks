extend Helper::Utils

def_settings = node.default['divelogger']['settings']
ext_settings = node['divelogger']['settings']
req_settings = ['cors', 'port', 'username', 'region', 'https', 'client_host', 'client_port']

valid_envs = ['development', 'staging', 'test', 'production']

if valid_envs.include? node['env']
  Chef::Log.info("********** ENVIRONMENT: '#{node['env']}' **********")
else
  raise 'No valid environment specified'
end

settings = Helper::Utils.get_settings(node['env'], def_settings, ext_settings, req_settings)

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
  key "#{node['env']}/divelogger.zip"
end

# Install application
bash 'setup-server' do
  cwd '/srv/www'
  user 'root'
  code <<-EOH
    rm -r divelogger
    unzip divelogger.zip -d divelogger
    cd divelogger
    mkdir log
    npm install
    cd ..
    mkdir /var/log/node
    chown -R www:www /var/log/node/
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
    echo "NODE_ENV=#{node['env']}" >.env
    echo "NODE_PORT=#{settings['port']}" >>.env
    echo "NODE_HTTPS=#{settings['https']}" >>.env
    echo "mongo_host=#{settings['mongo_host']}" >>.env
    echo "api_port=#{settings['port']}" >>.env
    echo "cors=#{settings['cors']}" >>.env
    echo "secretToken=#{settings['secretToken']}" >>.env
    echo "client_host=#{settings['client_host']}" >>.env
    echo "client_port=#{settings['client_port']}" >>.env
    touch start.sh
    echo "#!/bin/bash" >start.sh
    echo "/bin/bash -c 'cd /srv/www/divelogger ; source /srv/www/divelogger/.env ; /usr/bin/env PORT=#{settings['port']} NODE_PATH=/srv/www/divelogger/node_modules:/srv/www/divelogger /usr/local/bin/node /srv/www/divelogger/server.js 2>>/var/log/node/node.stderr.log 1>>/var/log/node/node.stdout.log'" >>start.sh
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
          'condition' => "failed port #{settings['port']} protocol HTTP request / with timeout 10 seconds",
          'action'    => 'restart'
      }
  ]
end

# Configure log rotation
logrotate_app 'node-divelogger' do
  path      ['/var/log/node/node.stderr.log', '/var/log/node/node.stdout.log']
  options   ['missingok', 'delaycompress', 'notifempty', 'sharedscripts', 'copytruncate']
  frequency 'weekly'
  rotate    4
  size      '100M'
  create    '644 www www'
end

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
