#!/bin/bash

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Allow group-writable files.
umask g+w

# Get the uri and webroot by stripping the prefix and suffix from the job name.
uri=$(echo ${JOB_NAME} | sed -e "s/^(.*\/)?${1}_//;s/--.*$//")
webroot="/var/www/${uri}/htdocs"
sqlconf="sql-conf"
sqlcli="sql-cli"

# Type is prefixed to some Drush commands for CiviCRM.
type=""

if echo ${JOB_NAME} | grep -q '\--'; then
  suffix=$(echo ${JOB_NAME} | sed -e 's/^.*--//')
  # CiviCRM is a special case. We distinguish it with a suffix, but it does not
  # have a separate uri or webroot.
  if [ "${suffix}" = "civicrm" ]; then
    type="civicrm-"
    sqlconf="${sqlconf} --target=civicrm"
    sqlcli="${sqlcli} --target=civicrm"
  fi
fi

# For easily executing Drush.
export TERM=dumb
drush="drush -v -r ${webroot} -l ${uri} -y"

# Test that the site is functional enough to return a non-error response. Also
# primes caches.
function test_site {
  curl --insecure --retry 3 --retry-delay 10 "https://drupal:drupal@${uri}" > /dev/null
}

# Swap the active and inactive databases
function swap_db {
  altdbloc="/var/www/${uri}/altdb"
  if [ -f ${altdbloc} ]; then
    rm ${altdbloc}
  else
    touch ${altdbloc}
  fi
}
