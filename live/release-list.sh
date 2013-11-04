#!/usr/bin/env bash

# This is all releases, not projects that are tagged, not including -dev
# releases, ordered by release date. A stopgap for localize.drupal.org's needs
# for https://drupal.org/node/669910.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

drush -r /var/www/drupal.org/htdocs -l drupal.org sql-cli > /var/www/drupal.org/htdocs/files/releases.tsv <<end
  SELECT from_unixtime(n.created) AS created,
    p.uri AS project_machine_name,
    pr.version,
    td.name AS api
  FROM node n
  INNER JOIN project_release_nodes pr ON pr.nid = n.nid AND pr.rebuild = 0
  INNER JOIN project_projects p ON p.nid = pr.pid
  INNER JOIN term_data td ON td.tid = pr.version_api_tid
  WHERE n.status = 1
  ORDER BY n.created DESC;
end

# D7
# SELECT
#   from_unixtime(n.created) AS created,
#   pm.field_project_machine_name_value AS project_machine_name,
#   rv.field_release_version_value AS version,
#   td.name AS api
# FROM node n
# INNER JOIN field_data_field_release_project rp ON rp.entity_id = n.nid
# INNER JOIN field_data_field_release_build_type rbt ON rbt.entity_id = n.nid AND rbt.field_release_build_type_value = 'static'
# INNER JOIN field_data_field_release_version rv ON rv.entity_id = n.nid
# INNER JOIN field_data_field_project_machine_name pm ON pm.entity_id = rp.field_release_project_target_id
# INNER JOIN field_data_taxonomy_vocabulary_6 ra ON ra.entity_id = n.nid
# INNER JOIN taxonomy_term_data td ON td.tid = ra.taxonomy_vocabulary_6_tid
# WHERE n.status = 1
# ORDER BY n.created DESC;