# Include common staging script.
. staging/common.sh 'deploy'

# Update code.
cd ${webroot}
git pull

# Clear caches, try updatedb.
${drush} cc all || true
# Temporary D7 upgrade steps for localize
if [ "${uri}" = "localize-7.staging.devdrupal.org" ]; then
  . /usr/local/drupal-infrastructure/staging/localize_7.sh
  localize_7_pre_update
fi
${drush} updatedb --interactive
${drush} cc all

# Also handle CiviCRM for the Association site.
if [ "${uri}" = "assoc.staging.devdrupal.org" ]; then
  ${drush} cc drush
  ${drush} compile-templates
elif [ "${uri}" = "localize-7.staging.devdrupal.org" ]; then
  localize_7_post_update
fi

test_site
