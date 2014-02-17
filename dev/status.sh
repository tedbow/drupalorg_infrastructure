# Collect general information about dev sites.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# For easily executing drush.
export TERM=dumb

{
  echo -n "Generated "
  date
  echo

  echo "Database"
  ssh devdb.drupal.org df -h /var
  echo

  for domain in $(ls "/var/www/dev"); do
    echo ${domain}
    cd "/var/www/dev/${domain}/htdocs"
    site=$(echo "${domain}" | sed -e 's/\.redesign\.devdrupal\.org$//;s/^.*-//')
    echo "SELECT from_unixtime(max(access)) AS 'Last access' FROM users;" | drush sql-cli | xargs echo
    bzr status || echo "BZR status failed!"
    echo
  done
} > "/var/www/dev-status.txt"
