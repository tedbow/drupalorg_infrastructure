<?php

/**
 * Find users that have not been synced properly, and sync them.
 */

$email_unvalidated_rid = variable_get('logintoboggan_pre_auth_role');
$count = 0;

foreach (variable_get('bakery_slaves', array()) as $slave) {
  // Make drush site alias records.
  $url = parse_url($slave);
  $site = array(
    'root' => '/var/www/' . ($url['host'] === 'assoc.drupal.org' ? 'association.drupal.org' : $url['host']) . '/htdocs',
  );

  // Find Drupal.org UIDs with email unverified role present on the site.
  $email_unvalidated = drush_invoke_process($site, 'vget', array('--exact', '--format=string', 'logintoboggan_pre_auth_role'));
  $output = drush_invoke_process($site, 'sql-query', array("SELECT u.init AS '' FROM users u INNER JOIN users_roles ur ON ur.uid = u.uid AND ur.rid = " . ((int) $email_unvalidated['output']) . " WHERE u.init LIKE 'www.drupal.org/user/%/edit'"));
  $site_uids = array_filter(preg_replace('#www.drupal.org/user/(\d+)/edit#', '\1', explode("\n", $output['output'])), 'is_numeric');
  drush_log(dt('@site has @count email unvalidated Drupal.org users', array('@site' => $url['host'], '@count' => count($site_uids))));

  // Find the UIDs that are not email unvalidated on Drupal.org.
  foreach (user_load_multiple(db_query('SELECT u.uid FROM users u LEFT JOIN users_roles ur ON ur.uid = u.uid AND ur.rid = :email_unvalidated_rid WHERE u.uid IN (:site_uids) AND ur.uid IS NULL', array(':email_unvalidated_rid' => $email_unvalidated_rid, ':site_uids' => $site_uids))->fetchCol()) as $account) {
    // Update them.
    drush_log(dt('Syncing @name', array('@name' => $account->name)));
    user_save($account);
    $count += 1;
  }
}

drush_log(dt('@count users synced', array('@count' => $count)));
