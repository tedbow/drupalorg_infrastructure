# Include common staging script.
. staging/common.sh 'snapshot_to'

# Get the DB name from drush
db=$(${drush} ${type}sql-conf | sed -ne 's/^\s*\[database\] => //p')

# If a snapshot has not been already set in $snapshot, get it from $uri,
# everything before the first '.'
[ "${snapshot-}" ] || snapshot=$(echo ${uri} | sed -e 's/\..*$//')

# Clear out the DB and import a snapshot.
(
  echo "DROP DATABASE ${db};"
  echo "CREATE DATABASE ${db};"
  echo "USE ${db};"
  ssh util cat "/var/dumps/mysql/${snapshot}_database_snapshot.staging-current.sql.bz2" | bunzip2
) | ${drush} ${type}sql-cli

# Extra preparation for D7.
if [ "${uri}" = "7.devdrupal.org" ]; then
  (
    # Apache Solr causes _node_types_build() to be called before node_update_7000().
    # Ported features containing fields that content_migrate touch need to be migrated with the feature disabled to
    # prevent data from going missing. (Presumably.)
    echo "UPDATE system SET status = 0 WHERE name IN ('apachesolr', 'apachesolr_search', 'apachesolr_multisitesearch', 'features');"
    # Officially associate the "Projects" vocabulary with projects -- it was being altered in in a hacky way, and taxonomy upgrade
    # thought it was unused.
    echo "INSERT IGNORE INTO vocabulary_node_types (vid, type) VALUES (3, 'project_project');"
  ) | ${drush} sql-cli


elif [ "${uri}" = "localize.7.devdrupal.org" ]; then
  (
    # OG needs new entity module.
    echo "UPDATE system SET status = 0 WHERE name IN ('og');"
  ) | ${drush} sql-cli
fi

# Try updatedb, clear caches.
#${drush} -v updatedb --interactive
${drush} -v updatedb --interactive || echo "SOME UPDATES FAILED BUT CONTINUING ANYWAY!!!!!!"
${drush} cc all

if [ "${uri}" = "7.devdrupal.org" ]; then
  # Do cck fields migration. (Fieldgroups, etc.)
  ${drush} en field_group
  ${drush} en content_migrate
  # Hack to try and convince drush to recognize the new commands.
  ${drush} dis content_migrate
  ${drush} en content_migrate
  # When prod is on 5.4 drush we can use this instead of all.
  #${drush} cc drush
  ${drush} cc all
  ${drush} content-migrate-fields
  ${drush} cc all

  ${drush} en features
  ${drush} fra
  # Re-enable & revert features. (disabled until the features are converted to
  # D7.)
  # ${drush} en drupalorg_change_notice
  # ${drush} fra

  # Do project issue import
  ${drush} en migrate_ui
  ${drush} cc all
  ${drush} ms
  ${drush} mi ProjectIssueFixInitFiles
  ${drush} mi ProjectIssueRethreadIssueFollowups
  ${drush} mi ProjectIssueTimelinePhaseOne
  ${drush} mi ProjectIssueTimelinePhaseTwo
  ${drush} mi ProjectIssueTimelinePhaseThree
  ${drush} mi ProjectIssueAllocateVidsMigration
  ${drush} mi ProjectIssueAllocateCidsMigration
  ${drush} mi ProjectIssueRebuildCommentFieldsMigration
  ${drush} mi ProjectIssueRebuildNodeFieldsMigration
  #${drush} mi ProjectIssuePhaseTwo
  ${drush} mi ProjectIssueFixGenericCorruption

  ${drush} dis content_migrate

elif [ "${uri}" = "localize.7.devdrupal.org" ]; then
  # OG needs to migrate data.
  ${drush} en og_migrate
  ${drush} og-migrate
  ${drush} dis og_migrate
fi

# Prime caches for home page and make sure site is basically working.
wget -O /dev/null http://${uri} --user=drupal --password=drupal
