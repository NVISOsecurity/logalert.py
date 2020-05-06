# works best when running the script as a periodic cron job which runs every minute.
# Detect new public IP address
cat /var/log/syslog |grep -a "Records updated with new IP at" | grep "$(date +"%b %d")" | grep -v CRON | grep -v -f /home/pi/scripts/logalert_whitelist.txt | /usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
