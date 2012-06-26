# Include common staging script.
. staging/common.sh 'deploy'

# Update code.
cd ${webroot}
bzr up

# updatedb, clear and prime caches.
${drush} updatedb -vd
${drush} cc all
wget -O /dev/null http://${uri} --user=drupal --password=drupal

# Save BZR revision number for build name.
bzr_revno=$(bzr version-info | sed -ne 's/^revno: //p')
