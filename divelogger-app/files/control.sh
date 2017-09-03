#!/bin/bash
DIR=/srv/www/divelogger
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
NODE_PATH=/usr/local/lib/node_modules
NODE=/usr/local/bin/node

test -x $NODE || exit 0

function start_app {
NODE_ENV=production nohup "$NODE" "$DIR/server.js" 1>>"$DIR/logs/divelogger.log" 2>&1 &
echo $! > "$DIR/pids/divelogger.pid"
}

function stop_app {
kill `cat $DIR/pids/divelogger.pid`
}

case $1 in
start)
start_app ;;
stop)
stop_app ;;
restart)
stop_app
start_app
;;
*)
echo "usage: YOUR_APP_NAME {start|stop}" ;;
esac
exit 0
