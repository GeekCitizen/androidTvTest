#!/bin/bash

# Uncomment to enable logs / Comment to disable logs
#LOGSENABLED="1"

TMPFILELOG=/tmp/adbcmd.log
TMPFILEERR=/tmp/adbcmd.err
TMPJSON=/tmp/json.txt
FINALSTATFILE=/usr/share/nginx/html/status.json
FINALSTATERR=/usr/share/nginx/html/status-err.txt
FINALSTATELOG=/usr/share/nginx/html/status-log.txt

TMPSTOPFILE=/tmp/STOPITNOW
rm -f $TMPFILELOG $TMPFILEERR $TMPSTOPFILE

function logIt {
	if [[ ! -z $LOGSENABLED ]];
	then echo $1;
	fi
}



# Check if IP has been given
if [[ -z $SRVIP ]]; then exit 12; fi


# Launch NGINX
nginx &


while true; do
	STATUSIN=1
	if [[ -f $TMPSTOPFILE ]]; then adb kill-server && exit; fi
	logIt "---- 001 start"
	if [[ ! -z $LOGSENABLED ]];
	then	adb start-server;
		adb connect $SRVIP;
	else 	adb start-server > /dev/null 2>&1;
		adb connect $SRVIP > /dev/null 2>&1;
	fi
	logIt "---- 001 end"

	sleep 1

	while [[ $STATUSIN -ne 0 ]]; do
		rm -f $TMPFILELOG $TMPFILEERR
		touch $TMPFILELOG $TMPFILEERR
		logIt "---- 002 start"
		# ANSWER=`adb shell dumpsys power | grep "Display Power" | cut -d'=' -f 2`
		adb shell dumpsys power > $TMPFILELOG 2>$TMPFILEERR

		cat $TMPFILEERR | grep "error" >/dev/null 2>&1
		STATUSIN=$?

		# ANSWER=`cat $TMPFILELOG  | grep "Display Power" | cut -d'=' -f 2`
		#for i in error ON OFF; do
			unset jsonPowerTMP jsonPower
			jsonPower=`cat ${TMPFILELOG} | grep "Display Power" | cut -d'=' -f 2 | tr -d "\r"` # | grep $i > /dev/null 2>&1 && echo $i` # > ${FINALSTATFILE}
			rm -f ${TMPJSON}
			echo "{" > ${TMPJSON}
			echo "\"TVStatus\": \"${jsonPower}\"" >> ${TMPJSON}
			echo -n "}" >> ${TMPJSON}
			cp ${TMPJSON} ${FINALSTATFILE}

			if [[ -f ${FINALSTATLOG} ]]; then rm -f ${FINALSTATELOG}; fi
			if [[ -f ${TMPFILELOG} ]]; then cp ${TMPFILELOG} ${FINALSTATELOG}; fi
			if [[ -f ${FINALSTATERR} ]]; then rm -f ${FINALSTATERR}; fi
			if [[ -f ${TMPFILEERR} ]]; then cp ${TMPFILEERR} ${FINALSTATERR}; fi
		#done
		logIt "Code 002 : $STATUSIN"
		logIt "---- 002 end"
		sleep 1
		if [[ -f $TMPSTOPFILE ]]; then break; fi
	done

	logIt "---- 003 start"
	if [[ ! -z $LOGSENABLED ]];
	then	adb disconnect $SRVIP;
		adb kill-server;
	else	adb disconnect $SRVIP > /dev/null 2>&1;
		adb kill-server > /dev/null 2>&1;
	fi
	logIt "---- 003 end"
	sleep 1
done
