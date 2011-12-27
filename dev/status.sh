# Collect general information about dev sites.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# For easily executing drush.
export TERM=dumb
drush="/usr/local/bin/drush"

{
  echo -n "Generated "
  date
  echo

  echo "Database"
  ssh stagingdb.drupal.org df -h /
  echo

  for domain in $(ls "/var/www/dev"); do
    echo ${domain}
    cd "/var/www/dev/${domain}/htdocs"
    site=$(echo "${domain}" | sed -e 's/\.redesign\.devdrupal\.org$//;s/^.*-//')
    if [ "${site}" = 'drupal' ]; then
      echo "SELECT from_unixtime(max(access)) AS 'Last access' FROM users_access;" | ${drush} sql-cli | xargs echo
    else
      echo "SELECT from_unixtime(max(access)) AS 'Last access' FROM users;" | ${drush} sql-cli | xargs echo
    fi
    bzr status
    echo
  done
} > "/var/www/dev-status.txt"
