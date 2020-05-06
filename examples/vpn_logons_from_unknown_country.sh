# works best when running the script as a periodic cron job which runs every minute.
# log VPN logons from unknown countries
cat /var/log/syslog | grep "docker-openvpn_server" | grep "Connection Initiated with" | grep -v CRON | cut -d "]" -f 4- | cut -d ":" -f 1 | xargs -r -n 1 geoiplookup {} |cut -d ":" -f 2- | cut -d "," -f 2-  | xargs -r -n 1 echo "VPN logon from" | grep -v -f /home/pi/scripts/logalert_whitelist.txt | /usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
