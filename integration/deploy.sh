# Include common integration script.
. integration/common.sh 'deploy'

# Update code.
cd ${webroot}
[ "${branch-}" ] && git fetch && git checkout "${branch}"
git pull

# Clear caches, try updatedb.
${drush} cc all || true

${drush} updatedb --interactive
${drush} cc all

# Also handle CiviCRM for the Association site.
if [ "${uri}" = "assoc.integration.devdrupal.org" ]; then
  ${drush} cc drush
  ${drush} compile-templates
fi

## Clean up solr and create a read-only core
#${drush} vset apachesolr_default_environment solr_0
#${drush} solr-set-env-url --id="solr_0" http://integrationsolr1.drupal.aws:8080/solr/do-core1
#${drush} solr-vset --id="solr_0" --yes apachesolr_read_only 1
#${drush} ev "apachesolr_environment_delete(solr_0_0)"

test_site
