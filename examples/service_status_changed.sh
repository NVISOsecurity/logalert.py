# works best when running the script as a periodic cron job which runs every minute.
# Detect service status changes - just an example, don't forget to update parameters and path to logalert!
sudo service --status-all | xargs -d "\n" -n 1 echo "Service status has changed: "| /usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
