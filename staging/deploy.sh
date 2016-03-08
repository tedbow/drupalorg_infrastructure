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

# Clean up solr and create a read-only core
${drush} vset apachesolr_default_environment solr_0
${drush} solr-set-env-url --id="solr_0" http://stagingsolr1.drupal.aws:8080/solr/do-core1
${drush} solr-vset --id="solr_0" --yes apachesolr_read_only 1
${drush} ev "apachesolr_environment_delete(solr_0_0)"

test_site
