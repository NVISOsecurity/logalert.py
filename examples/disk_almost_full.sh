# works best when running the script as a periodic cron job which runs every minute.
# log disk almost full alerts
df -akh / | cut -d "%" -f 1,2 | grep -o '[0-9]\+%' |xargs -n 1 echo "Disk used:" | grep -o '[8-9][0-9]%' | grep -v CRON | grep -v -f /home/pi/scripts/logalert_whitelist.txt | /usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
