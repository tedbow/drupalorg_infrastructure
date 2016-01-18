# Include common staging script.
. staging/common.sh 'deploy'

# Update code.
cd ${webroot}
git pull

# Clear caches, try updatedb.
# Note: Commented out. updb should operate first. Cache clear happens after updb.
#${drush} cc all || true

${drush} updatedb --interactive

# Also handle CiviCRM for the Association site.
if [ "${uri}" = "assoc.staging.devdrupal.org" ]; then
  ${drush} cc drush
  ${drush} compile-templates
fi

test_site
