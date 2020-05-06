# works best when running the script as a periodic cron job which runs every minute.
# log IDS alerts
cat /media/NAS/logs/raspberrypi/suricata/eve.json |grep "$(date +"%Y-%m-%d")" |grep '"alert"'| grep -v '"severity":3' | grep -v CRON | grep -v -f /home/pi/scripts/logalert_whitelist.txt | /usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
