<?php

// Delete GitLab user and project IDs that had been pulled down from the DB
// dump and replace them with IDs matched up to the GitLab dev instance.

$client = versioncontrol_gitlab_get_client();
$pager = new VersioncontrolGitlabResultPager($client);

// Match up GitLab user IDs to GitLab dev.
db_delete('versioncontrol_gitlab_users')->execute();
$query = db_insert('versioncontrol_gitlab_users')->fields(['gitlab_user_id', 'uid']);
foreach ($pager->fetchall($client->api('users'), 'all') as $gitlab_user) {
  if (preg_match('/@([0-9]*)\.no-reply\.drupal\.org/', $gitlab_user['email'], $match)) {
    $query->values([
      'gitlab_user_id' => $gitlab_user['id'],
      'uid' => $match[1],
    ]);
  }
}
$query->execute();

// Match up GitLab project IDs to GitLab dev.
db_delete('versioncontrol_gitlab_repositories')->execute();
$gitlab_projects = [];
foreach ($pager->fetchall($client->api('projects'), 'all') as $gitlab_project) {
  if (in_array($gitlab_project['namespace']['name'], ['project', 'sandbox'])) {
    $gitlab_projects[$gitlab_project['name']] = [
      'gitlab_project_id' => $gitlab_project['id'],
      'namespace' => $gitlab_project['namespace']['name'],
    ];
  }
}
$query = db_insert('versioncontrol_gitlab_repositories')->fields(['gitlab_project_id', 'namespace', 'repo_id']);
foreach (db_query('SELECT name, repo_id FROM {versioncontrol_repositories} WHERE name IN (:names)', [':names' => array_keys($gitlab_projects)])->fetchAllKeyed() as $name => $repo_id) {
  $query->values($gitlab_projects[$name] + ['repo_id' => $repo_id]);
}
$query->execute();
