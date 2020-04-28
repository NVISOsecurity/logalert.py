# logalert v0.1 - Daan Raman - @daanraman
import util
import sys
import config

# Prepare the local alerting cache if it does not exist yet
util.create_cache_if_not_exists()

# Remove all cache hits older than the cache lifetime
util.prune_old_cache_items()

# Process all piped standard input
for line in sys.stdin:
    raw_alert = line.strip()
    if config.args.verbose:
        print("processing standard input - " + raw_alert)

    first_match_date, first_match_date_txt, no_timestamp_alert = util.extract_timestamp_from_alert(raw_alert)

    # If we have no timestamp, we don't do anything at all
    if first_match_date is None:
        if config.args.verbose:
            print("no timestamp extracted from log file - " + raw_alert)

    if config.args.verbose:
        print("extracted date text - " + str(first_match_date_txt))
        print("extracted date - " + str(first_match_date))

    # We need to check if we have already recently reported on this line or not
    if util.check_alert_against_cache(raw_alert):
        continue

    # Update the cache
    util.add_alert_to_cache(first_match_date, first_match_date_txt, no_timestamp_alert, raw_alert)

    # Send out email
    if not config.args.verbose:
        util.email_alert(raw_alert, first_match_date_txt)


