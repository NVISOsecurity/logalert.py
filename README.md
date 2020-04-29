# logalert.py

Smart piping of standard output to email for alerting.

```
usage: logalert.py [-h] [-v] [-c CONFIG]

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         shows debug output, does not send emails
  -c CONFIG, --config CONFIG
                        specify a custom configuration file (default:
                        logalert.conf)
```
## Introduction
``logalert.py`` can be used to pipe standard output to email.
A simple caching system is used to avoid sending duplicate
alerts within a certain timeframe.

The tool was developed for cases where you want a simple and 
robust way of being alerted whenever something interesting
happens on a system.

## How to use

There is a simple configuration file to complete with the details
of your mail server and account settings. An example is provided
in ``logalert.conf``.

Once the configuration file has been completed, standard output
can be sent to e-mail by "piping" standard output into it:

``echo "Hello World" | python logalert.py -c logalert.conf``

The message will arrive as an alert in your inbox!

![Hello World](screnshots/Hello_World.png "Hello World")


## Configuration

All parameters to configure including documentationare listed
in the example configuration file [``logalert.conf``](logalert.conf).  


## Examples
``logalerty.py`` can be used for a wide variety of cases where you
want to be alerted of activity on a computer. A few examples:

### Alert on logging of high severity IDS alerts
``cat /var/log/suricata/eve.json | grep -v '"severity":3' | python logalert.py -c logalert.conf``

### Alert on potential overheating of a Raspberry pi
``vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*' 
| grep -o '[8-9][3-9]\.[0-9]' 
| xargs -n 1 echo "Raspberry Pi temprature:" 
| xargs -d '\n' -n 1 echo "$(date +"%Y-%m-%d %H:%M")"
| grep  '[8-9][3-9]\.[0-9]' 
| python logalert.py -c logalert.conf``

### Alert on a disk filling
``df -akh / | cut -d "%" -f 1,2 | grep -o '[0-9]\+%' 
|xargs -n 1 echo "Disk used:" | grep -o '[8-9][0-9]%'
| grep -v CRON | python logalert.py -c logalert.conf``

### Detect VPN logons from a suspicious country
``cat /var/log/syslog | grep "$(date +"%b %d")" 
| grep "docker-openvpn_server" 
| grep "Connection Initiated with" 
| grep -v CRON 
| cut -d "]" -f 4- | cut -d ":" -f 1 
| xargs -n 1 geoiplookup {} |cut -d ":" -f 2- 
| cut -d "," -f 2-  | xargs -n 1 echo "VPN logon from" 
| python logalert.py -c logalert.conf
``

## Contact
logalert.py is developed & maintained by NVISO Labs.

You can reach out to the developers by creating an issue in github.
For any other communication, you can reach out by sending us an e-mail 
at [research@nviso.eu](mailto:research@nviso.eu).

We write about our research on our blog: https://blog.nviso.eu  
You can follow us on twitter: https://twitter.com/NVISO_Labs

Thank you for using logalert.py and we look forward to your feedback! 🐀

## License
logalert.py is released under the [GNU GENERAL PUBLIC LICENSE v3 (GPL-3).](https://tldrlegal.com/license/gnu-general-public-license-v3-(gpl-3))
