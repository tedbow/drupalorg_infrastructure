#!/usr/bin/env bash

# Gather extended information for issues tagged 'Drupal.org D7'.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

drush -r /var/www/drupal.org/htdocs -l drupal.org sql-cli > /var/www/association.drupal.org/htdocs/files/d7-issues.tsv <<end
  SELECT
    n.nid,
    n.title AS Issue,
    ifnull(group_concat(DISTINCT td_p.name ORDER BY td_p.name ASC), '') AS Sections,
    n_p.title Project,
    pip.name Priority,
    pis.name AS State,
    ifnull(max(cast(td_h.name AS signed)), '') AS Hours,
    u.name AS Assigned
  FROM node n
  INNER JOIN term_node tn ON tn.vid = n.vid INNER JOIN term_data td ON td.tid = tn.tid AND td.name = 'Drupal.org D7'
  INNER JOIN project_issues pi ON pi.nid = n.nid
  INNER JOIN project_issue_state pis ON pis.sid = pi.sid AND (pis.default_query = 1 OR pis.name = 'closed (fixed)')
  INNER JOIN project_issue_priority pip ON pip.priority = pi.priority
  INNER JOIN users u ON u.uid = pi.assigned
  INNER JOIN node n_p ON n_p.nid = pi.pid
  LEFT JOIN term_node tn_h ON tn_h.vid = n.vid LEFT JOIN term_data td_h ON td_h.tid = tn_h.tid AND td_h.name LIKE '%hr'
  LEFT JOIN term_node tn_p ON tn_p.vid = n.vid LEFT JOIN term_data td_p ON td_p.tid = tn_p.tid AND td_p.name IN ('project', 'git', 'solr', 'bluecheese', 'porting', 'cleanup', 'infrastructure', 'qa', 'testbot')
  GROUP BY n.nid
  ORDER BY pis.name = 'closed (fixed)', pis.name = 'fixed', Sections DESC, pip.weight, pis.weight, Hours DESC;
end
