#!/bin/bash
# works best when running the script as a periodic cron job which runs every minute.
# On the first of the month, send a confirmation that everything is still running smooothly.

# This could also be done as a monthly cron, but I keep it simple and add the below to my crob job that runs
# each minute, along with all of the other alerting commands.
# Just an example, don't forget to update parameters and path to logalert!
day_of_month=$(date +%d)

if [[ "${day_of_month}" = "01" ]];
then
   echo "monthly logalert.py health check - everything is running smoothly" | /usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
fi
