#!/bin/bash -m

if [ "x$1" == "x1" ]
then
	rm -f /tmp/*.cronwget.pid
fi

TODO="echo 123 | wall"
TIMETOSLEEP=10

SELFNAME=$0
OLDPIDFILE=`ls -1 /tmp/*.cronwget.pid 2>/dev/null | head 2>/dev/null`
PID=`echo $OLDPIDFILE | xargs basename 2>/dev/null | awk -F "." '{print $1}'`
NEWPIDFILE="/tmp/$$.cronwget.pid"

function runcron {
	md5sum $SELFNAME > $NEWPIDFILE
	
	while [ true ] ; do
		sleep $TIMETOSLEEP &
		sh -c $TODO
		wait

		if [ "x`md5sum $SELFNAME`" != "x`cat $NEWPIDFILE`" ]
		then
			#file was midifed
			break
		fi
	done
	nohup $SELFNAME 1 2>/dev/null 1>&2 &
}

#check for run cron
if [ ! -f "$OLDPIDFILE" ]
then
	#no pid file found.
	runcron
	exit
fi

#check for currently run
ps ax | awk '{ print $1 }' | grep -q $PID || {
	#pid file is not valid
	rm -f /tmp/*.cronwget.pid
	runcron
}

#nothing to be done — process run
