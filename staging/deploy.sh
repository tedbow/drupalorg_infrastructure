# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Allow group-writable files.
umask g+w

# Get the domain name by stripping deploy_ from front of the job name.
domain=$(echo ${JOB_NAME} | sed -e 's/^deploy_//')

# For easily executing Drush.
export TERM=dumb
drush="drush -r /var/www/${domain}/htdocs -l ${domain} -y"

# Update code and keep track of versions.
cd /var/www/${domain}/htdocs
before=$(bzr version-info | grep "^revno: ")
bzr up
after=$(bzr version-info | grep "^revno: ")

# If an update happened, try updatedb, clear and prime caches.
if [ "${before}" != "${after}" ]; then
  ${drush} updatedb
  ${drush} cc all
  wget -O /dev/null http://${domain} --user=drupal --password=drupal
fi
