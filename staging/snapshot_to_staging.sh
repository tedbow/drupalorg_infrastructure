# Include common staging script.
. staging/common.sh 'snapshot_to'

# Get the DB name from drush
db=$(${drush} ${type}sql-conf | sed -ne 's/^\s*\[database\] => //p')

# If a snapshot has not been already set in $snapshot, get it from $uri,
# everything before the first '.'
[ "${snapshot-}" ] || snapshot=$(echo ${uri} | sed -e 's/\..*$//')

# If a snapshot type has been designated, use that. Otherwise, default to
# the 'staging' snapshot.
[ "${snaptype-}" ] || snaptype=staging

# Clear out the DB and import a snapshot.
(
  echo "DROP DATABASE ${db};"
  echo "CREATE DATABASE ${db};"
  echo "USE ${db};"
  ssh util cat "/var/dumps/mysql/${snapshot}_database_snapshot.${snaptype}-current.sql.bz2" | bunzip2
) | ${drush} ${type}sql-cli

# Extra preparation for D7.
if [ "${uri}" = "7.devdrupal.org" ]; then
  (
    # Ported features containing fields that content_migrate touch need to be migrated with the feature disabled to
    # prevent data from going missing. (Presumably.)
    #echo "UPDATE system SET status = 0 WHERE name IN ('project_solr', 'drupalorg_search', 'features');"
    echo "UPDATE system SET status = 0 WHERE name = 'features';"
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
${drush} -v updatedb --interactive
#${drush} -v updatedb --interactive || echo "SOME UPDATES FAILED BUT CONTINUING ANYWAY!!!!!!"
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

  # Show current status for debugging purposes.
  ${drush} content-migrate-status

  # Migrate all fields.
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
  ${drush} mi ProjectIssueAllocateVids
  ${drush} mi ProjectIssueAllocateCids
  ${drush} mi ProjectIssueRebuildCommentFields
  ${drush} mi ProjectIssueRebuildNodeFields
  #${drush} mi ProjectIssuePhaseTwo
  ${drush} mi ProjectIssueFixGenericCorruption

  ${drush} dis content_migrate

  ${drush} en conflict

  # https://drupal.org/node/1830028
  ${drush} association-members || echo "Association members failed but continuing anyway!"

  # Reenable drupal.org search.
  ${drush} en drupalorg_search
  # Force the system to notice the facets.
  ${drush} cc all

elif [ "${uri}" = "localize.7.devdrupal.org" ]; then
  # OG needs to migrate data.
  ${drush} en og_migrate
  ${drush} og-migrate
  ${drush} dis og_migrate
fi

# Prime caches for home page and make sure site is basically working.
wget -O /dev/null http://${uri} --user=drupal --password=drupal
