<?php

$limit = (int) getenv('limit');

foreach (variable_get('bakery_slaves', []) as $slave) {
  // Make drush site alias records.
  $url = parse_url($slave);
  $site = [
    'root' => '/var/www/' . ($url['host'] === 'assoc.drupal.org' ? 'association.drupal.org' : $url['host']) . '/htdocs',
  ];

  // Find Drupal.org UIDs present on the site.
  $output = drush_invoke_process($site, 'sql-query', ["SELECT init AS '' FROM users WHERE init LIKE 'www.drupal.org/user/%/edit'"]);
  $site_uids = array_filter(preg_replace('#www.drupal.org/user/(\d+)/edit#', '\1', explode("\n", $output['output'])), 'is_numeric');
  drush_log(dt('@site has @count total Drupal.org users', ['@site' => $url['host'], '@count' => count($site_uids)]));

  // Find the UIDs not present on Drupal.org.
  // Create a temp table of the subsite's Drupal.org UIDs.
  $temp_table = Database::getConnection()->queryTemporary('SELECT uid FROM {users} LIMIT 1');
  db_delete($temp_table)->execute();
  foreach (array_chunk($site_uids, 10000) as $chunk) {
    $query = db_insert($temp_table)->fields(['uid']);
    foreach ($chunk as $site_uid) {
      $query->values(['uid' => $site_uid]);
    }
    $query->execute();
  }
  // Select the uids which are not in the users table.
  $query = db_select($temp_table, 'temp')->fields('temp', ['uid']);
  $query->leftJoin('users', 'u', 'u.uid = temp.uid');
  $query->isNull('u.uid');
  $deleted_uids = $query->execute()->fetchCol();
  drush_log(dt('@site has @count users not present on Drupal.org', ['@site' => $url['host'], '@count' => count($deleted_uids)]));

  if (count($deleted_uids) > $limit) {
    // Bail if there are a lot of users to delete.
    drush_log(dt('Too many users to delete! Drupal.org UIDs are @uids', ['@uids' => implode(', ', $deleted_uids)]), 'error');
    exit(1);
  }
  elseif (count($deleted_uids)) {
    // Delete the users.
    foreach ($deleted_uids as $uid) {
      $output = drush_invoke_process($site, 'sql-query', ["charset utf8; SELECT name AS '' FROM users WHERE init = 'www.drupal.org/user/" . $uid . "/edit'"]);
      $name = trim($output['output']);
      if ($name[0] === '-') {
        // Bail if the username starts with a dash.
        drush_log(dt('Can’t delete @name on @site, starts with a dash', ['@name' => $name, '@site' => $url['host']]), 'error');
        exit(1);
      }
      if (!empty($name)) {
        drush_log(dt('Deleting @name on @site', ['@name' => $name, '@site' => $url['host']]));
        drush_invoke_process($site, 'user-cancel', [$name]);
      }
    }
  }
}
