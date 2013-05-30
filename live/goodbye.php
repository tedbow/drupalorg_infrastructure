<?php

// Get bakery slaves into drush site alias records.
$sites = array();
foreach (variable_get('bakery_slaves', array()) as $slave) {
  $url = parse_url($slave);
  $sites[$url['host']] = array('root' => '/var/www/' . $url['host'] . '/htdocs');
}

// Read emails from stdin.
foreach (file('php://stdin') as $mail) {
  $mail = trim($mail);
  // Find Drupal.org UID.
  $uid = db_result(db_query("SELECT uid FROM {multiple_email} WHERE email = '%s'", $mail));
  if ($uid === FALSE) {
    // Non-matching email.
    print '### Not found: ' . $mail . "\n";
  }
  else {
    $account = user_load($uid);
    print $mail . ' was "' . $account->name . '" ' . url('user/' . $account->uid, array('absolute' => TRUE)) . "\n";

    // Update username to 'no longer here UID' init, mail, status
    $array = array(
      'name' => 'no longer here ' . $account->uid,
      'init' => 'deletion-requested@' . $account->uid . '.invalid',
      'mail' => 'deletion-requested@' . $account->uid . '.invalid',
      'status' => 0,
    );
    // Remove data.
    $data = unserialize($account->data);
    if (is_array($data)) {
      foreach (array_keys($data) as $key) {
        $data[$key] = NULL;
      }
    }
    user_save($account, $array);

    // Remove profile & multiple_email data.
    db_query('DELETE FROM {profile_values} WHERE uid = %d', $account->uid);
    db_query('DELETE FROM {multiple_email} WHERE uid = %d', $account->uid);

    // Subsites: bakery should forward the status and invalidated mail. We
    // should remove profile values. No other sites run multiple email.
    foreach ($sites as $site) {
      $output = drush_invoke_process($site, 'sql-query', array("SELECT uid AS '' FROM users WHERE init = 'drupal.org/user/" . $account->uid . "/edit'"));
      if (!empty($output['output'])) {
        $slave_uid = trim($output['output']);
        drush_invoke_process($site, 'sql-query', array('DELETE FROM profile_values WHERE uid = ' . $slave_uid));
      }
    }
  }
}
