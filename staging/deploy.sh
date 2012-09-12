# Include common staging script.
. staging/common.sh 'deploy'

# Update code.
cd ${webroot}
bzr up

# updatedb, clear and prime caches.
${drush} updatedb --interactive
${drush} cc all
wget -O /dev/null http://${uri} --user=drupal --password=drupal
