<?php
// The issue for automation is https://drupal.org/node/2193959

$month = (int) getenv('month');
if (empty($month)) {
  $month = gmdate('n') - 1;
}
$year = (int) getenv('year');

$function = getenv('testbot') ? 'run_queries_testbot' : 'run_queries';

print "Month:\n";
print_r($function(array(
  ':start' => gmmktime(0, 0, 0, $month, 1, $year),
  ':end' => gmmktime(0, 0, 0, $month + 1, 1, $year),
)));
print "YTD:\n";
print_r($function(array(
  ':start' => gmmktime(0, 0, 0, 1, 1, $year),
  ':end' => gmmktime(0, 0, 0, $month + 1, 1, $year),
)));
print "DCI:\n";
print_r(run_queries_dci(array(
  ':start' => gmmktime(0, 0, 0, 1, 1, $year),
  ':end' => gmmktime(0, 0, 0, $month + 1, 1, $year),
)));

function run_queries($args) {
  print date('c', $args[':start']) . ' to ' . date('c', $args[':end']) . "\n";
  $data = array();

  // Number of Active Accounts (logged in 1x per period of time)
  $data['accounts_logged_in'] = db_query("SELECT COUNT(*) FROM {users} WHERE status = 1 AND access > :start AND :end", $args)->fetchField();

  // Number of Active Accounts (at least 1 activity per period of time)
  $data['accounts_active'] = count(array_unique(array_merge(
    db_query('SELECT DISTINCT u.uid FROM {comment} c INNER JOIN {users} u ON u.status = 1 AND u.uid = c.uid WHERE c.status = 1 AND c.created BETWEEN :start AND :end', $args)->fetchCol(),
    db_query('SELECT DISTINCT u.uid FROM {node_revision} nr INNER JOIN {users} u ON u.status = 1 AND u.uid = nr.uid WHERE nr.status = 1 AND nr.timestamp BETWEEN :start AND :end', $args)->fetchCol(),
    db_query('SELECT DISTINCT u.uid FROM {versioncontrol_operations} o INNER JOIN {users} u ON u.status = 1 AND u.uid = o.author_uid WHERE o.committer_date BETWEEN :start AND :end', $args)->fetchCol()
  )));

  // Number of Blocked Accounts (on this specific date)
  $data['accounts_blocked'] = db_query("SELECT COUNT(*) FROM {users} WHERE status=0")->fetchField();

  // Number of Participants in the Issue Queues (who commented)
  $data['accounts_issue_commented'] = db_query("SELECT COUNT(DISTINCT(c.uid))
    FROM {comment} c
    INNER JOIN {node} n ON c.nid = n.nid AND n.status = 1
    INNER JOIN {users} u ON u.uid = c.uid AND u.status = 1
    WHERE n.type = 'project_issue' AND c.status = 1 
    AND c.created BETWEEN :start AND :end", $args)->fetchField();

  // Number of Participants in the Drupal Core Issue Queue (who commented)
  $data['accounts_issue_commented_core'] = db_query("SELECT COUNT(DISTINCT(c.uid))
    FROM {comment} c
    INNER JOIN {field_data_field_project} fdfp ON fdfp.entity_id = c.nid AND fdfp.field_project_target_id = 3060
    INNER JOIN {node} n ON c.nid = n.nid AND n.type = 'project_issue' AND n.status = 1
    INNER JOIN {users} u ON u.uid = c.uid AND u.status = 1
    WHERE c.status = 1 
    AND c.created BETWEEN :start AND :end", $args)->fetchField();

  // Number of Commits across All Projects
  $data['commits'] = db_query("SELECT COUNT(DISTINCT vco.revision) AS commits 
    FROM {versioncontrol_operations} vco 
    WHERE vco.committer_date BETWEEN :start AND :end", $args)->fetchField();

  // Number of Commits to Drupal Core
  $data['commits_core'] = db_query("SELECT COUNT(DISTINCT vco.revision) AS commits 
    FROM {versioncontrol_operations} vco 
    WHERE vco.repo_id=2 AND vco.committer_date BETWEEN :start AND :end", $args)->fetchField();

  // Number of Committers (at least 1 commit, all full projects, excluding Core)
  $data['commiters'] = db_query("SELECT COUNT(DISTINCT vco.committer) AS committers
    FROM {versioncontrol_operations} vco
    INNER JOIN {versioncontrol_project_projects} vp ON vp.repo_id = vco.repo_id AND vp.nid <> 3060
    INNER JOIN {field_data_field_project_type} t ON t.entity_id = vp.nid AND t.field_project_type_value = 'full'
    WHERE vco.committer_date BETWEEN :start AND :end", $args)->fetchField();

  // Number of Commits per User (excluding commits to Drupal Core)
  // (overall commits / # of committers, both numbers excluding Drupal core and sandboxes)
  $data['commits_per_user'] = db_query("SELECT COUNT(DISTINCT vco.revision) / COUNT(DISTINCT vco.committer) AS commits_per_committer
    FROM {versioncontrol_operations} vco
    INNER JOIN {versioncontrol_project_projects} vp ON vp.repo_id = vco.repo_id AND vp.nid <> 3060
    INNER JOIN {field_data_field_project_type} t ON t.entity_id = vp.nid AND t.field_project_type_value = 'full'
    WHERE vco.committer_date BETWEEN :start AND :end", $args)->fetchField();

  // Number of Comments (created during the time period)
  $data['comments'] = db_query("SELECT COUNT(c.cid) comments
    FROM {comment} c
    INNER JOIN {node} n ON c.nid = n.nid AND n.status = 1
    INNER JOIN {users} u ON u.uid = c.uid AND u.status = 1
    WHERE c.status = 1 AND c.created BETWEEN :start AND :end", $args)->fetchField();

  // Number of Comments on Issues (created during the time period)
  $data['comments_issues'] = db_query("SELECT COUNT(c.cid) comments 
    FROM {comment} c
    INNER JOIN {node} n ON n.nid = c.nid AND n.type = 'project_issue' AND n.status = 1
    INNER JOIN {users} u ON u.uid = c.uid AND u.status = 1
    WHERE c.status = 1 AND c.created BETWEEN :start AND :end", $args)->fetchField();

  // Number of Comments on Drupal Core Issues (created during the time period)
  $data['comments_issues_core'] = db_query("SELECT COUNT(c.cid) comments 
    FROM {comment} c
    INNER JOIN {field_data_field_project} fdfp ON fdfp.entity_id = c.nid AND fdfp.field_project_target_id = 3060
    INNER JOIN {node} n ON n.nid = c.nid AND n.type = 'project_issue' AND n.status = 1
    INNER JOIN {users} u ON u.uid = c.uid AND u.status = 1
    WHERE c.status = 1 AND c.created BETWEEN :start AND :end", $args)->fetchField();

  // Average Number of Comments per User (created during the time period)
  // (overall comments / # of commenters)
  $data['comments_per_user'] = db_query("SELECT COUNT(c.cid) / COUNT(DISTINCT c.uid) AS comments_per_user
    FROM {comment} c
    INNER JOIN {node} n ON c.nid = n.nid AND n.status = 1
    INNER JOIN {users} u ON u.uid = c.uid AND u.status = 1
    WHERE c.status = 1 AND c.created BETWEEN :start AND :end", $args)->fetchField();

  // Average Number of Comments per User on Issues 
  $data['comments_per_user_issue'] = db_query("SELECT COUNT(c.cid) / COUNT(DISTINCT c.uid) AS comments_per_user
    FROM {comment} c
    INNER JOIN {node} n ON c.nid = n.nid AND n.type = 'project_issue' AND n.status = 1
    INNER JOIN {users} u ON u.uid = c.uid AND u.status = 1
    WHERE c.status = 1 AND c.created BETWEEN :start AND :end", $args)->fetchField();

  // Average Number of Comments per User on Drupal Core Issues
  $data['comments_per_user_issue_core'] = db_query("SELECT COUNT(c.cid) / COUNT(DISTINCT c.uid) AS comments_per_user
    FROM {comment} c
    INNER JOIN {field_data_field_project} fdfp ON fdfp.entity_id = c.nid AND fdfp.field_project_target_id = 3060
    INNER JOIN {node} n ON c.nid = n.nid AND n.type = 'project_issue' AND n.status = 1
    INNER JOIN {users} u ON u.uid = c.uid AND u.status = 1
    WHERE c.status = 1 AND c.created BETWEEN :start AND :end", $args)->fetchField();

  // Number of Comments on Issues, which Updated the Node
  $data['comments_issues_update'] = db_query("SELECT COUNT(c.cid) comments 
    FROM {comment} c
    INNER JOIN {node} n ON n.nid = c.nid AND n.status = 1
    INNER JOIN {field_data_field_issue_changes} ic ON ic.entity_id = c.cid
    INNER JOIN {users} u ON u.uid = c.uid AND u.status = 1
    WHERE c.status = 1 AND c.created BETWEEN :start AND :end", $args)->fetchField();

  // Number of Issues (created during the time period)
  $data['issues'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {users} u ON u.uid = n.uid AND u.status = 1
    WHERE n.type = 'project_issue' AND n.status = 1 AND n.created BETWEEN :start AND :end", $args)->fetchField();

  // Average Number of Issues per User (created during the time period)
  $data['issues_per_user'] = db_query("SELECT COUNT(n.nid) / COUNT(DISTINCT n.uid) AS issues_per_user
    FROM {node} n
    INNER JOIN {users} u ON u.uid = n.uid AND u.status = 1
    WHERE n.type = 'project_issue' AND n.status = 1 AND n.created BETWEEN :start AND :end", $args)->fetchField();

  // Number of Projects (created during the time period)
  $data['projects'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {users} u ON u.uid = n.uid AND u.status = 1
    INNER JOIN {field_data_field_project_type} t ON t.entity_id = n.nid
    WHERE n.status = 1 AND n.created BETWEEN :start AND :end", $args)->fetchField();

  // Number of Sandbox Projects (created during the time period)
  $data['projects_sandbox'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {users} u ON u.uid = n.uid AND u.status = 1
    INNER JOIN {field_data_field_project_type} t ON t.entity_id = n.nid AND t.field_project_type_value = 'sandbox'
    WHERE n.status = 1 AND n.created BETWEEN :start AND :end", $args)->fetchField();

  // Number of Full Projects (created during the time period)
  $data['projects_full'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {users} u ON u.uid = n.uid AND u.status = 1
    INNER JOIN {field_data_field_project_type} t ON t.entity_id = n.nid AND t.field_project_type_value = 'full'
    WHERE n.status = 1 AND n.created BETWEEN :start AND :end", $args)->fetchField();

  // Total number of Projects
  $data['total_projects'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {users} u ON u.uid = n.uid AND u.status = 1
    INNER JOIN {field_data_field_project_type} t ON t.entity_id = n.nid
    WHERE n.status = 1")->fetchField();

  // Total number of Sandbox Projects
  $data['total_projects_sandbox'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {users} u ON u.uid = n.uid AND u.status = 1
    INNER JOIN {field_data_field_project_type} t ON t.entity_id = n.nid AND t.field_project_type_value = 'sandbox'
    WHERE n.status = 1")->fetchField();

  // Total number of Full Projects
  $data['total_projects_full'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {users} u ON u.uid = n.uid AND u.status = 1
    INNER JOIN {field_data_field_project_type} t ON t.entity_id = n.nid AND t.field_project_type_value = 'full'
    WHERE n.status = 1")->fetchField();

  // Support
  // % issues about Drupal.org responded to in 48 hours
  // (% of issues, created during the time period, which received first comment, not from the issue author, in less than 48 hours after issue published, in the following queues: Content, Webmasters, Infrastructure, Bluecheese, Drupalorg, Drupalorg_crosssite)
  $data['issues_responded'] = db_query("SELECT sum(duration / 60 / 60 <= 48) / count(1) * 100 FROM (SELECT (min(c.created) - n.created) AS duration FROM {node} n INNER JOIN {field_data_field_project} fp ON fp.entity_id = n.nid AND fp.field_project_target_id IN (1848824, 3202, 107028, 651778, 185188, 1540220) INNER JOIN {comment} c ON c.nid = n.nid AND c.uid <> n.uid WHERE n.type = 'project_issue' AND n.created BETWEEN :start AND :end GROUP BY n.nid ORDER BY NULL) t", $args)->fetchField();

  // Number of Open Issues per Queue

  // Content
  $data['issues_content'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {field_data_field_project} fp ON fp.entity_id = n.nid AND fp.field_project_target_id = 1848824
    INNER JOIN {field_data_field_issue_status} fis ON fis.entity_id = n.nid
    WHERE fis.field_issue_status_value IN (1,13,8,14,15,4,16)")->fetchField();

  // Webmasters
  $data['issues_webmasters'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {field_data_field_project} fp ON fp.entity_id = n.nid AND fp.field_project_target_id = 3202
    INNER JOIN {field_data_field_issue_status} fis ON fis.entity_id = n.nid
    WHERE fis.field_issue_status_value IN (1,13,8,14,15,4,16)")->fetchField();

  // Infrastructure
  $data['issues_infrastructure'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {field_data_field_project} fp ON fp.entity_id = n.nid AND fp.field_project_target_id = 107028
    INNER JOIN {field_data_field_issue_status} fis ON fis.entity_id = n.nid
    WHERE fis.field_issue_status_value IN (1,13,8,14,15,4,16)")->fetchField();

  // Bluecheese
  $data['issues_bluecheese'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {field_data_field_project} fp ON fp.entity_id = n.nid AND fp.field_project_target_id = 651778
    INNER JOIN {field_data_field_issue_status} fis ON fis.entity_id = n.nid
    WHERE fis.field_issue_status_value IN (1,13,8,14,15,4,16)")->fetchField();

  // Drupalorg
  $data['issues_drupalorg'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {field_data_field_project} fp ON fp.entity_id = n.nid AND fp.field_project_target_id = 185188
    INNER JOIN {field_data_field_issue_status} fis ON fis.entity_id = n.nid
    WHERE fis.field_issue_status_value IN (1,13,8,14,15,4,16)")->fetchField();

  // Drupalorg_crosssite
  $data['issues_drupalorg_crosssite'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {field_data_field_project} fp ON fp.entity_id = n.nid AND fp.field_project_target_id = 1540220
    INNER JOIN {field_data_field_issue_status} fis ON fis.entity_id = n.nid
    WHERE fis.field_issue_status_value IN (1,13,8,14,15,4,16)")->fetchField();

  // G.d.o queue
  $data['issues_groups'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {field_data_field_project} fp ON fp.entity_id = n.nid AND fp.field_project_target_id = 833750
    INNER JOIN {field_data_field_issue_status} fis ON fis.entity_id = n.nid
    WHERE fis.field_issue_status_value IN (1,13,8,14,15,4,16)")->fetchField();

  // A.d.o queue
  $data['issues_association_drupalorg'] = db_query("SELECT COUNT(n.nid)
    FROM {node} n
    INNER JOIN {field_data_field_project} fp ON fp.entity_id = n.nid AND fp.field_project_target_id = 1369118
    INNER JOIN {field_data_field_issue_status} fis ON fis.entity_id = n.nid
    WHERE fis.field_issue_status_value IN (1,13,8,14,15,4,16)")->fetchField();

  // Average Response Time across All Queues (hours)
  // (avg. time between issue published and 1st comment, not by issue author, created)
  $data['issues_response_time'] = db_query("SELECT avg(duration) / 60 / 60 FROM (SELECT (min(c.created) - n.created) AS duration FROM {node} n INNER JOIN {comment} c ON c.nid = n.nid AND c.uid <> n.uid WHERE n.type = 'project_issue' AND n.created BETWEEN :start AND :end GROUP BY n.nid ORDER BY NULL) t", $args)->fetchField();

  // Average Response Time in Drupal Core Issue Queue (hours)
  $data['issues_response_time_core'] = db_query("SELECT avg(duration) / 60 / 60 FROM (SELECT (min(c.created) - n.created) AS duration FROM {node} n INNER JOIN {field_data_field_project} fp ON fp.entity_id = n.nid AND fp.field_project_target_id = 3060 INNER JOIN {comment} c ON c.nid = n.nid AND c.uid <> n.uid WHERE n.type = 'project_issue' AND n.created BETWEEN :start AND :end GROUP BY n.nid ORDER BY NULL) t", $args)->fetchField();

  // Average Response Time in Drupal.org Issue Queues (hours)
  // (Content, Webmasters, Infrastructure, Bluecheese, Drupalorg, Drupalorg_crosssite)
  $data['issues_response_time_drupalorg'] = db_query("SELECT avg(duration) / 60 / 60 FROM (SELECT (min(c.created) - n.created) AS duration FROM {node} n INNER JOIN {field_data_field_project} fp ON fp.entity_id = n.nid AND fp.field_project_target_id IN (1848824, 3202, 107028, 651778, 185188, 1540220) INNER JOIN {comment} c ON c.nid = n.nid AND c.uid <> n.uid WHERE n.type = 'project_issue' AND n.created BETWEEN :start AND :end GROUP BY n.nid ORDER BY NULL) t", $args)->fetchField();

  // Number of Drupal core downloads
  $data['downloads_core'] = db_query("SELECT td.name, sum(rfd.field_release_file_downloads_value)
    FROM {field_data_field_release_files} rf 
    INNER JOIN {field_data_field_release_project} rp ON rp.entity_id = rf.entity_id AND rp.field_release_project_target_id = 3060 
    INNER JOIN {field_data_taxonomy_vocabulary_6} api ON api.entity_id = rf.entity_id 
    INNER JOIN {taxonomy_term_data} td ON td.tid = api.taxonomy_vocabulary_6_tid 
    INNER JOIN {field_data_field_release_file_downloads} rfd ON rfd.entity_id = rf.field_release_files_value 
    GROUP BY api.taxonomy_vocabulary_6_tid")->fetchAllAssoc('name');

  return $data;
}

/**
 * DrupalCI (queries against Drupal.org db)
 */

function run_queries_dci($args) {
  $data = array();

  // # of test requests sent
  $result = db_query("SELECT MONTH(FROM_UNIXTIME(cijob.created)) AS Month, count(*) AS Tests, sum(ttd.name = '8.x' ) AS D8, sum(ttd.name = '7.x' ) AS D7, sum(ttd.name = '6.x' ) AS D6, sum(ttd.name = '8.x' ) + sum(ttd.name = '7.x' ) + sum(ttd.name = '6.x' ) AS TOTAL
FROM pift_ci_job cijob
  LEFT JOIN node release_node on release_node.nid = cijob.release_nid
  LEFT JOIN taxonomy_index ti on ti.nid = release_node.nid
  LEFT JOIN taxonomy_term_data ttd on ttd.tid = ti.tid
  LEFT JOIN field_data_field_release_project fdfrp on fdfrp.entity_id = release_node.nid
  LEFT JOIN node project_node on project_node.nid = fdfrp.field_release_project_target_id

WHERE YEAR(FROM_UNIXTIME(cijob.created)) = 2015
  AND project_node.nid = 3060
  AND release_node.type = 'project_release'
  AND ttd.name in ('6.x','7.x','8.x')
  AND ttd.vid = 6
GROUP BY MONTH(FROM_UNIXTIME(cijob.created))");
  while ($data['core_test_count'][] = db_fetch_array($result)) {
  }

  $result = db_query("SELECT MONTH(FROM_UNIXTIME(cijob.created)) AS Month, count(*) AS Tests, sum(ttd.name = '8.x' ) AS D8, sum(ttd.name = '7.x' ) AS D7, sum(ttd.name = '6.x' ) AS D6, sum(ttd.name = '8.x' ) + sum(ttd.name = '7.x' ) + sum(ttd.name = '6.x' ) AS TOTAL
FROM pift_ci_job cijob
  LEFT JOIN node release_node on release_node.nid = cijob.release_nid
  LEFT JOIN taxonomy_index ti on ti.nid = release_node.nid
  LEFT JOIN taxonomy_term_data ttd on ttd.tid = ti.tid
  LEFT JOIN field_data_field_release_project fdfrp on fdfrp.entity_id = release_node.nid
  LEFT JOIN node project_node on project_node.nid = fdfrp.field_release_project_target_id

WHERE YEAR(FROM_UNIXTIME(cijob.created)) = 2015
  AND project_node.nid != 3060
  AND release_node.type = 'project_release'
  AND ttd.name in ('6.x','7.x','8.x')
  AND ttd.vid = 6
GROUP BY MONTH(FROM_UNIXTIME(cijob.created))");
  while ($data['contrib_test_count'][] = db_fetch_array($result)) {
  }

  $result = db_query("SELECT MONTH(FROM_UNIXTIME(cijob.created)) AS Month, AVG(cijob.updated - cijob.created)/60 AS Duration
FROM pift_ci_job cijob
  LEFT JOIN node release_node on release_node.nid = cijob.release_nid
  LEFT JOIN taxonomy_index ti on ti.nid = release_node.nid
  LEFT JOIN taxonomy_term_data ttd on ttd.tid = ti.tid
  LEFT JOIN field_data_field_release_project fdfrp on fdfrp.entity_id = release_node.nid
  LEFT JOIN node project_node on project_node.nid = fdfrp.field_release_project_target_id

WHERE YEAR(FROM_UNIXTIME(cijob.created)) = 2015
  AND project_node.nid = 3060
  AND cijob.environment = 'php5.5_mysql5.5'
  AND release_node.type = 'project_release'
  AND ttd.name = '8.x'
  AND ttd.vid = 6
GROUP BY MONTH(FROM_UNIXTIME(cijob.created))");
  while ($data['d8_core_avg_time'][] = db_fetch_array($result)) {
  }

  $result = db_query("SELECT MONTH(FROM_UNIXTIME(cijob.created)) AS Month, AVG(cijob.updated - cijob.created)/60 AS Duration
FROM pift_ci_job cijob
  LEFT JOIN node release_node on release_node.nid = cijob.release_nid
  LEFT JOIN taxonomy_index ti on ti.nid = release_node.nid
  LEFT JOIN taxonomy_term_data ttd on ttd.tid = ti.tid
  LEFT JOIN field_data_field_release_project fdfrp on fdfrp.entity_id = release_node.nid
  LEFT JOIN node project_node on project_node.nid = fdfrp.field_release_project_target_id

WHERE YEAR(FROM_UNIXTIME(cijob.created)) = 2015
  AND project_node.nid = 3060
  AND release_node.type = 'project_release'
  AND ttd.name = '7.x'
  AND ttd.vid = 6
GROUP BY MONTH(FROM_UNIXTIME(cijob.created))");
  while ($data['d7_core_avg_time'][] = db_fetch_array($result)) {
  }

  return $data;
}

/**
 * Testbot (queries against qa.d.o)
 */
function run_queries_testbot($args) {
  $data = array();

  // Drupal 6 time warp!

  // # of test requests sent
  $result = db_query("SELECT MONTH(FROM_UNIXTIME(last_received)), COUNT(test_id) FROM {pifr_test} WHERE type IN (2,3) AND status = 4 AND YEAR(FROM_UNIXTIME(last_received)) = 2015 GROUP BY MONTH(FROM_UNIXTIME(last_received))");
  while ($data['test_count'][] = db_fetch_array($result)) {
  }

  // # of Drupal core patches tested / Average core test queue time (min) / Average core test duration (min) / Average core total wait time (min)
  $result = db_query("SELECT MONTH(FROM_UNIXTIME(pt.last_received)), YEAR(FROM_UNIXTIME(pt.last_received)), COUNT(pt.test_id), AVG((pt.last_requested - pt.last_received)/60) AS avg_queue_time, AVG((pt.last_tested - pt.last_requested)/60) AS avg_test_duration, AVG((pt.last_tested - pt.last_received)/60) AS avg_total_wait FROM {pifr_test} pt LEFT JOIN {pifr_file} pf ON pt.test_id = pf.test_id WHERE pt.type = 3 AND pt.status = 4 AND pf.branch_id IN (1,2,29488,29453) AND pt.last_requested != 0 AND YEAR(FROM_UNIXTIME(last_received)) = 2015 GROUP BY YEAR(FROM_UNIXTIME(last_received)), MONTH(FROM_UNIXTIME(last_received))");
  while ($data['test_core'][] = db_fetch_array($result)) {
  }

  // Same, D7 only
  $result = db_query("SELECT MONTH(FROM_UNIXTIME(pt.last_received)), YEAR(FROM_UNIXTIME(pt.last_received)), COUNT(pt.test_id), AVG((pt.last_requested - pt.last_received)/60) AS avg_queue_time, AVG((pt.last_tested - pt.last_requested)/60) AS avg_test_duration, AVG((pt.last_tested - pt.last_received)/60) AS avg_total_wait FROM {pifr_test} pt LEFT JOIN {pifr_file} pf ON pt.test_id = pf.test_id WHERE pt.type = 3 AND pt.status = 4 AND pf.branch_id = 1 AND pt.last_requested != 0 AND YEAR(FROM_UNIXTIME(last_received)) = 2015 GROUP BY YEAR(FROM_UNIXTIME(last_received)), MONTH(FROM_UNIXTIME(last_received))");
  while ($data['test_core_d7'][] = db_fetch_array($result)) {
  }

  // Same, D8 only
  $result = db_query("SELECT MONTH(FROM_UNIXTIME(pt.last_received)), YEAR(FROM_UNIXTIME(pt.last_received)), COUNT(pt.test_id), AVG((pt.last_requested - pt.last_received)/60) AS avg_queue_time, AVG((pt.last_tested - pt.last_requested)/60) AS avg_test_duration, AVG((pt.last_tested - pt.last_received)/60) AS avg_total_wait FROM {pifr_test} pt LEFT JOIN {pifr_file} pf ON pt.test_id = pf.test_id WHERE pt.type = 3 AND pt.status = 4 AND pf.branch_id IN (2,29488,29453) AND pt.last_requested != 0 AND YEAR(FROM_UNIXTIME(last_received)) = 2015 GROUP BY YEAR(FROM_UNIXTIME(last_received)), MONTH(FROM_UNIXTIME(last_received))");
  while ($data['test_core_d8'][] = db_fetch_array($result)) {
  }

  return $data;
}
