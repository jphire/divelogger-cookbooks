#!monit 
set logfile /var/log/monit.log 
check process nodejs with pidfile "/srv/www/divelogger/pids/divelogger.pid" 
start program = "/etc/init.d/node_app start" 
stop program = "/etc/init.d/node_app stop" 
if failed port 3001 protocol HTTP 
request / 
with timeout 10 seconds
then restart
