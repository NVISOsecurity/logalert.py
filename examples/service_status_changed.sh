# works best when running the script as a periodic cron job which runs every minute.
# Detect service status changes - just an example, don't forget to update parameters and path to logalert!
# This will alert on every service the first time it runs - after that, it will only alert on changes (since the first status will be part of the cache by then)
sudo service --status-all | xargs -d "\n" -n 1 echo "Service status has changed: "| /usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
