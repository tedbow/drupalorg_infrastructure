# Include common staging script.
. staging/common.sh 'deploy'

# Update code.
cd ${webroot}

if [ -d .bzr ]; then
 bzr up
else 
 git pull
fi

# updatedb, clear and prime caches.
${drush} -v updatedb --interactive
${drush} cc all
# Also handle CiviCRM for the Association site.
if [ "${uri}" = "association.staging.devdrupal.org" ]; then
  ${drush} cc civicrm
  ${drush} compile-templates
fi

test_site
