import os
import json
import email.utils
from email.mime.text import MIMEText
import smtplib
from datetime import datetime, timedelta
from dateutil.tz import tzlocal
import platform
import datefinder
import iso8601
import config
import sys

# Extract the full path to the cache file
file = sys.argv[0]
pathname = os.path.dirname(file)
CACHE_FULL_PATH_NAME = os.path.join(os.path.abspath(pathname), config.CACHE_FILE_NAME)


def create_cache_if_not_exists():
    if os.path.exists(CACHE_FULL_PATH_NAME):
        # If the cache is corrupt, recreate it
        with open(CACHE_FULL_PATH_NAME, mode='r+') as cache_json:
            try:
                json.load(cache_json)
                if config.args.verbose:
                    print("valid cache file detected")

            except json.decoder.JSONDecodeError:
                fresh_cache = {"cache": list()}
                cache_json.seek(0)
                json.dump(fresh_cache, cache_json, indent=4)
                if config.args.verbose:
                    print("invalid cache file, reset to emtpy cache")

    # The cache does not exist, create it
    else:
        data = {"cache": list()}

        with open(CACHE_FULL_PATH_NAME, 'w') as outfile:
            if config.args.verbose:
                print("cache file not detected, generating")
            json.dump(data, outfile)


def prune_old_cache_items():
    pruned_cache = []
    cache_should_be_pruned = False

    with open(CACHE_FULL_PATH_NAME, mode='r') as cache_json:
        existing_cache = json.load(cache_json)
        for cache_item in existing_cache["cache"]:
            cache_item_date_processed = iso8601.parse_date(cache_item["timestamp_processed"])
            if cache_item_date_processed < datetime.now(tzlocal()) - timedelta(hours=config.ALERT_MUTE_TIME_HOURS):
                cache_should_be_pruned = True
                if config.args.verbose:
                    print("removing pruned item from cache - " + str(cache_item["raw_alert"]))
            else:
                pruned_cache.append(cache_item)

    if cache_should_be_pruned:
        with open(CACHE_FULL_PATH_NAME, 'w') as outfile:
            if config.args.verbose:
                print("updating cache file after pruning old items")
            json.dump({ "cache": pruned_cache}, outfile, indent=4)


def extract_timestamp_from_alert(alert):
    extracted_timestamp = datefinder.find_dates(alert, source=True, strict=False)
    if extracted_timestamp:
        try:
            first_match_date, first_match_date_txt = next(extracted_timestamp)
            alert_message_no_time = alert.replace(first_match_date_txt, '').strip()
            return first_match_date, first_match_date_txt, alert_message_no_time
        except StopIteration:
            return None, None, alert
    else:
        return None, None, alert


def get_current_cache_size():
    current_cache_size = 0

    with open(CACHE_FULL_PATH_NAME, mode='r') as cache_json:
        existing_cache = json.load(cache_json)

        for _ in existing_cache["cache"]:
            current_cache_size = current_cache_size + 1

    return current_cache_size


def cache_is_full():
    if get_current_cache_size() >= config.CACHE_MAX_SIZE:
        return True
    else:
        return False


def check_alert_against_cache(raw_alert):
    with open(CACHE_FULL_PATH_NAME, mode='r') as cache_json:
        existing_cache = json.load(cache_json)

        for cache_item in existing_cache["cache"]:
            if cache_item["raw_alert"] == raw_alert:
                if config.args.verbose:
                    print("cache hit, not reporting again - " + raw_alert)
                return True

    if config.args.verbose:
        print("no cache hit - " + raw_alert)
    return False


def add_alert_to_cache(first_match_date, first_match_txt, no_timestamp_alert, raw_alert):
    cache_item_to_add = {"timestamp_processed": datetime.now().isoformat()}

    cache_item_to_add["timestamp_extracted_date"] = str(first_match_date)
    cache_item_to_add["timestamp_extracted_text"] = str(first_match_txt)

    cache_item_to_add["no_timestamp_alert"] = no_timestamp_alert
    cache_item_to_add["raw_alert"] = raw_alert

    with open(CACHE_FULL_PATH_NAME, mode='r+') as cache_json:
        existing_cache = json.load(cache_json)
        existing_cache["cache"].append(cache_item_to_add)
        cache_json.seek(0)
        json.dump(existing_cache, cache_json, indent=4)


def summarize_string(_str, maxlength):
    if len(_str) < maxlength:
        return _str
    else:
        return _str[0:maxlength] + "..."


def email_alert(alert, first_match_date_txt):
    server = smtplib.SMTP(config.SMTP_SERVER, config.SMTP_PORT)
    server.ehlo()
    server.starttls()
    server.ehlo()
    server.login(config.SMTP_USER, config.SMTP_PASSWORD)

    msg = MIMEText(alert)

    msg['From'] = email.utils.formataddr(('logalert', config.SENDER))
    msg['To'] = email.utils.formataddr(('Recipient', config.RECIPIENT))

    if first_match_date_txt is None:
        first_match_date_txt = "<no timestamp extracted>"

    msg['Subject'] = '[logalert @ ' + platform.node() + ' - ' + first_match_date_txt + '] ' + summarize_string(alert, 50)
    server.sendmail(config.SENDER, config.RECIPIENT, msg.as_string())
