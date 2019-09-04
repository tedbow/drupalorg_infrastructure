<?php

// Queues importing a project from https://git.drupalcode.org production to
// dev.

list(,, $project) = drush_get_arguments();
if (empty($project)) {
  drush_log(dt('Project (machine name or nid) argument is required.'), 'error');
  return;
}
$node = project_load($project);
if (!drush_confirm(dt('Queue !nid !title? Any existing project in GitLab DEV should be deleted first.', ['!nid' => $node->nid, '!title' => $node->title]))) {
  return;
}
$repo = $node->versioncontrol_project['repo'];
$repo->description = t('For more information about this repository, visit the project page at !url', ['!url' => url('node/' . $node->nid, ['absolute' => TRUE])]);
$repo->namespace = project_promote_project_is_sandbox($node) ? 'sandbox' : 'project';
DrupalQueue::get('versioncontrol_repomgr')->createItem([
  'operation' => [
    'import' => ['https://git.drupalcode.org/' . preg_replace('#^/var/git/repositories/#', '', $repo->root)],
  ],
  'repository' => $repo,
]);
