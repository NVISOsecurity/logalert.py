# works best when running the script as a periodic cron job which runs every minute.
# alert on recently (re)started docker containers - just an example, don't forget to update parameters and path to logalert!
docker ps| grep seconds | /usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
