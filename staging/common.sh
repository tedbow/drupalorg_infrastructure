# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Allow group-writable files.
umask g+w

# Get the uri and webroot by stripping the prefix and suffix from the job name.
uri=$(echo ${JOB_NAME} | sed -e "s/^${1}_//;s/--.*$//")
webroot="/var/www/${uri}/htdocs"

# Type is prefixed to some Drush commands for CiviCRM.
type=""

if echo ${JOB_NAME} | grep -q '\--'; then
  # deploy_association.drupal.org--intranet -> intranet
  suffix=$(echo ${JOB_NAME} | sed -e 's/^.*--//')
  # CiviCRM is a special case. We distinguish it with a suffix, but it does not
  # have a separate uri or webroot.
  if [ "${suffix}" = "civicrm" ]; then
    type="civicrm-"
  else
    webroot="${webroot}/${suffix}"
    uri="${uri}/${suffix}"
  fi
fi

# For easily executing Drush.
export TERM=dumb
drush="drush -r ${webroot} -l ${uri} -y"

# Test that the site is functional enough to return a non-error response. Also
# primes caches.
function test_site {
  wget -O /dev/null "http://${uri}" --user=drupal --password=drupal --no-check-certificate
}
