# works best when running the script as a periodic cron job which runs every minute.
# Alert on Raspberry Pi running hot (limit is 83 degrees)
vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*' | grep -o '[8-9][3-9]\.[0-9]' | xargs -n 1 echo "Raspberry Pi temprature:" | xargs -d '\n' -n 1 echo "$(date +"%Y-%m-%d %H:%M")"| grep  '[8-9][3-9]\.[0-9]' | grep -v CRON | grep -v -f /home/pi/scripts/logalert_whitelist.txt | /usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
