# Include common staging script.
. staging/common.sh 'deploy'

# Update code.
cd ${webroot}

if [ -d .bzr ]; then
 bzr up
else 
 git pull
fi

# Clear caches, try updatedb.
${drush} cc all
${drush} -v updatedb --interactive

# Also handle CiviCRM for the Association site.
if [ "${uri}" = "assoc.staging.devdrupal.org" ]; then
  ${drush} cc civicrm
  ${drush} compile-templates
fi

test_site
