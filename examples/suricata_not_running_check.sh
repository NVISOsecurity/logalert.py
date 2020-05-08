#!/bin/bash
# works best when running the script as a periodic cron job which runs every minute.
# Check if suricata is running or not
# Just an example, don't forget to update parameters and path to logalert!

suricata_running=$(ps -aux |grep suricata |grep -v grep |wc -l)

if [[ "${suricata_running}" = "0" ]];
then
   echo "suricata appears to be down! (no suricata process running)" |/usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
fi
