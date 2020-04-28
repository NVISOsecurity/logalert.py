import argparse
import configparser

# Configure & read command line parameters
parser = argparse.ArgumentParser()
parser.add_argument('-v', '--verbose', action='store_true', help="shows debug output, does not send emails")
parser.add_argument('-c', '--config', type=str, default="logalert.conf", help="specify a custom configuration file (default: logalert.conf)")
args = parser.parse_args()

# Load in the configuration file
config = configparser.ConfigParser()
config.read(args.config)

# Read out variables
SENDER = config['logalert']['SENDER']
RECIPIENT = config['logalert']['RECIPIENT']
SMTP_USER = config['logalert']['SMTP_USER']
SMTP_PASSWORD = config['logalert']['SMTP_PASSWORD']
SMTP_SERVER = config['logalert']['SMTP_SERVER']
SMTP_PORT = int(config['logalert']['SMTP_PORT'])
ALERT_MUTE_TIME_HOURS = int(config['logalert']['ALERT_MUTE_TIME_HOURS'])
CACHE_FILE_NAME = config['logalert']['CACHE_FILE_NAME']
