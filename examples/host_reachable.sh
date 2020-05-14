# Check if NAS is still reachable
ping 192.168.2.180 -c 1|grep "Destination Host Unreachable"| /usr/bin/python /home/pi/scripts/logalert.py/logalert.py -c /home/pi/scripts/logalert.py/logalert-pi-private.conf
