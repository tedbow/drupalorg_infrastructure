# Include common staging script.
. staging/common.sh 'deploy'

# Update code.
cd /var/www/${domain}/htdocs
bzr up

# updatedb, clear and prime caches.
${drush} updatedb
${drush} cc all
wget -O /dev/null http://${domain} --user=drupal --password=drupal
