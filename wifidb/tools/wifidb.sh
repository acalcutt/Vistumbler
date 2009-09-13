#!/bin/bash
# Start/stop WiFiDB server instance
# WiFiDB v0.16 Alpha 3.
#
# create as: /etc/init.d/wifidb
# to activate it, run: chkconfig -add wifidb

### BEGIN INIT INFO
# Provides: wifidb daemon
# Required-Start: mysql
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Start/stop wifidb server instance
### END INIT INFO

# LSB Source function library
. /lib/lsb/init-functions

RETVAL=0

# SCRIPT DEFAULT SETTINGS
prog="WiFiDBd"
wifidbpath="/CLI"
logpath="/var/log/wifidb"
wdbpid="/var/run/wifidbd.pid"
lockfile="/var/lock/WiFiDB"

start() {
	echo $"Starting $prog: "
    if [ -f $wdbpid ]
    then
		# failed
		log_failure_msg "$prog is already running..."
		echo
		RETVAL=2
    else
        output=`nohup php ${wifidbpath}/daemon/wifidbd.php > $logpath &`
		sleep 10s
        if [ -e $wdbpid ]
        then
			# success
            touch $lockfile
            log_success_msg "$prog started..."
            echo
            RETVAL=0
        else
			# failed
			log_failure_msg "$prog failed to start..."
			echo
			RETVAL=1
        fi
    fi
    return $RETVAL
}

stop() {
    echo $"Stopping $prog: "
    output=`php ${wifidbpath}/rund.php stop`
	if [ -f $wdbpid ]
	then
        # failed
        log_failure_msg "$wdbpid still exists. $prog was not stopped properly..."
		RETVAL=1
    else
        # success
		rm $lockfile
        log_success_msg "$prog stopped..."
        echo
        RETVAL=0
    fi
    return $RETVAL
}

restart() {
   stop
   start
}

status() {
	echo "checking: $wdbpid.."
    if [ -f $wdbpid ]
    then
		echo "$wdbpid file exists."
		echo "WifiDB is running"
    else
        echo "$wdbpid file does not exist"
		echo "WifiDB is not running"
    fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  restart)
    restart
    ;;
  condrestart)
    [ -e $lockfile ] && restart
    ;;
  force-reload)
    echo "WiFiDB doesn't support force-reload, use restart instead."
    ;;
  *)
    echo $"Usage: $0 {start|stop|status|restart|condrestart}"
    RETVAL=2
esac

exit $RETVAL