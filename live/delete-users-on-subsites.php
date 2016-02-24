<?php

$limit = (int) getenv('limit');

foreach (variable_get('bakery_slaves', array()) as $slave) {
  // Make drush site alias records.
  $url = parse_url($slave);
  $site = array(
    'root' => '/var/www/' . ($url['host'] === 'assoc.drupal.org' ? 'association.drupal.org' : $url['host']) . '/htdocs',
  );

  // Find Drupal.org UIDs present on the site.
  $output = drush_invoke_process($site, 'sql-query', array("SELECT init AS '' FROM users WHERE init LIKE 'www.drupal.org/user/%/edit'"));
  $site_uids = array_filter(preg_replace('#www.drupal.org/user/(\d+)/edit#', '\1', explode("\n", $output['output'])), 'is_numeric');
  drush_log(dt('@site has @count total Drupal.org users', array('@site' => $url['host'], '@count' => count($site_uids))));

  // Find the UIDs not present on Drupal.org.
  // Create a temp table of the subsite's Drupal.org UIDs.
  $temp_table = Database::getConnection()->queryTemporary('SELECT uid FROM {users} LIMIT 1');
  db_delete($temp_table)->execute();
  foreach (array_chunk($site_uids, 10000) as $chunk) {
    $query = db_insert($temp_table)->fields(array('uid'));
    foreach ($chunk as $site_uid) {
      $query->values(array('uid' => $site_uid));
    }
    $query->execute();
  }
  // Select the uids which are not in the users table.
  $query = db_select($temp_table, 'temp')->fields('temp', array('uid'));
  $query->leftJoin('users', 'u', 'u.uid = temp.uid');
  $query->isNull('u.uid');
  $deleted_uids = $query->execute()->fetchCol();
  drush_log(dt('@site has @count users not present on Drupal.org', array('@site' => $url['host'], '@count' => count($deleted_uids))));

  if (count($deleted_uids) > $limit) {
    // Bail if there are a lot of users to delete.
    drush_log(dt('Too many users to delete! Drupal.org UIDs are @uids', array('@uids' => implode(', ', $deleted_uids))), 'error');
    exit(1);
  }
  elseif (count($deleted_uids)) {
    // Delete the users.
    foreach ($deleted_uids as $uid) {
      $output = drush_invoke_process($site, 'sql-query', array("charset utf8; SELECT name AS '' FROM users WHERE init = 'www.drupal.org/user/" . $uid . "/edit'"));
      $name = trim($output['output']);
      if (!empty($name)) {
        drush_log(dt('Deleting @name on @site', array('@name' => $name, '@site' => $url['host'])));
        drush_invoke_process($site, 'user-cancel', array($name));
      }
    }
  }
}
