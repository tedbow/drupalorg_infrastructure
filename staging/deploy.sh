# Include common staging script.
. staging/common.sh 'deploy'

# Update code.
cd ${webroot}
bzr up

# updatedb, clear and prime caches.
${drush} -v updatedb --interactive
${drush} cc all
test_site
