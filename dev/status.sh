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
  # @TODO: Don't use an ssh session for this
  #ssh devdb.drupal.aws df -h /var/lib/mysql
  echo

  for domain in $(ls "/var/www/dev"); do
    echo ${domain}
    cd "/var/www/dev/${domain}/htdocs"
    site=$(echo "${domain}" | sed -e 's/\.redesign\.devdrupal\.org$//;s/^.*-//')
    echo "SELECT from_unixtime(max(access)) AS 'Last access' FROM users;" | drush sql-cli | xargs echo
    echo
  done
} > "/var/www/dev-status.txt"
