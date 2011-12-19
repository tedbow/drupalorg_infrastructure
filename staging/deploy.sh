# Include common staging script.
. staging/common.sh 'deploy'

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
