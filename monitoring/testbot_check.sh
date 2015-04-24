#!/bin/bash

# Checks the qa.drupal.org database to see if any testbot clients last activity was over two hours ago.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# .slackkeys contains a file like so:
##!/bin/bash
#ROOMKEY=/{HASH}/{HASH}/{HASH}
source /usr/local/drupal-infrastructure/monitoring/.slackkeys

cd /var/www/qa.drupal.org/htdocs
TESTBOTS=`/usr/bin/drush sqlc < /usr/local/drupal-infrastructure/monitoring/testbot_check.sql |awk 'BEGIN{ORS="\\\\n";}NR > 1 {print "Client #" $4 ": " $5 " Idle for more than 1 hour. Last activity was : " $1,$2 " GMT"} '`

curl -X POST --data-urlencode 'payload={"channel": "#testbots", "username": "PIFR the pufferfish", "text": "'"${TESTBOTS}"'", "icon_emoji": ":puffer:"}' https://hooks.slack.com/services/${ROOMKEY}
