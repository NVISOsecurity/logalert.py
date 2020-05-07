# works best when running the script as a periodic cron job which runs every minute.
# log firewall accepts from unknown countries - just an example, don't forget to update parameters and path to logalert!

# Register for your own API key here: https://www.abuseipdb.com/
ABUSEIPDBKEY="<YOUR API KEY HERE>"

# Run through all firewall accept messages
cat /var/log/syslog |grep "kernel: ACCEPT"| while read -r line ; do
   # Info will either contain something like 'Firewall accept from: Germany' or
   # nothing (in case of whitelisting). Based on that, we can decide in the script what to do.
   info=$(echo "$line" |cut -d " " -f 10 |cut -d "=" -f 2 | xargs -r -n 1 geoiplookup {} |cut -d ":" -f 2- | cut -d "," -f 2-  | cut -d " " -f 2- |xargs -d '\n' -r -n 1 echo "Firewall accept from"| grep -v -f /home/pi/scripts/logalert_whitelist.txt)

   # If the info variable is empty, it means the specific country is whitelisted - do not alert
   if [ -z "$info" ]
   then
     # Don't do anything
     :
   else
        # Also parse out the raw IP out of the connection log, we need it later for the abuse lookup
        ip=$(echo "$line" |cut -d " " -f 10 |cut -d "=" -f 2)

        # If the specific country is not whitelisted, then we are going to check abuse information.
        # If the abuse score is 0, meaning it's NOT a known attacking host (and likely an automated scan), we want to report on it!
	      abuseinfo=$(echo $ip | xargs -I{} curl -G -s https://api.abuseipdb.com/api/v2/check --data-urlencode "ipAddress={} " -d maxAgeInDays=90 -H "Key: $ABUSEIPDBKEY" -H "Accept: application/json" |grep '"abuseConfidenceScore":0')

        if [ -z "$abuseinfo" ]
          then
              # Don't do anything
              :
          else
              # Firewall accept from an unknown country, and from an IP address that is not yet known as being an abuser - report!
              echo "$info - $line - $abuseinfo"| /usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
        fi
   fi
done
