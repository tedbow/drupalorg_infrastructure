#!/bin/bash

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

# Clean up solr (if enabled)
if ${drush} pm-list --status=enabled | grep -q apachesolr; then
  ${drush} vset apachesolr_default_environment solr_0
  ${drush} solr-set-env-url --id="solr_0" http://solrstg-vip.drupal.bak:8983/solr/do-core1
  ${drush} ev "apachesolr_environment_delete(solr_0_0)"
fi

test_site
