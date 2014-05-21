<?php

// Check for required, forbidden, and discouraged projects.
$projects = explode("\n", getenv('projects'));
$projects_missing = array_diff(array(
  'security_review',
  'paranoia',
  'bakery',
  'drupalorg_crosssite',
), $projects);
$projects_forbidden = array_intersect(array(
  'devel',
), $projects);
$projects_discouraged = array_intersect(array(
  'views_ui',
), $projects);

$features = array();
$header = array('name', 'diff');
foreach (preg_split('/(^|\n)==== /', getenv('features'), -1, PREG_SPLIT_NO_EMPTY) as $feature) {
  $features[] = array_combine($header, explode("\n", $feature, 2));
}

?><!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Site status</title>

    <link href="css/bootstrap.min.css" rel="stylesheet">
  </head>
  <body>
    <div class="container">

      <h2>Code</h2>

      <p><span class="badge"><?php print getenv('version'); ?></span> is deployed.</p>
      <?php if (getenv('version') !== getenv('version_available')) { ?>
        <div class="alert alert-info"><span class="badge"><?php print getenv('version_available'); ?></span> is available.</div>
      <?php } ?>

      <?php if (getenv('repo_status')) { ?>
        <div class="panel panel-danger">
          <div class="panel-heading"><h3 class="panel-title">Local changes!</h3></div>
          <div class="panel-body">
            <h4>Status</h4>
            <pre><code><?php print htmlspecialchars(getenv('repo_status')); ?></code></pre>
            <h4>Diff</h4>
            <pre><code><?php print htmlspecialchars(getenv('repo_diff')); ?></code></pre>
          </div>
        </div>
      <?php } ?>


      <h2>Drupal</h2>

      <?php if (!empty($projects_missing)) { ?>
        <div class="alert alert-danger"><strong>Required project missing:</strong>
          <?php print implode(', ', $projects_missing); ?></div>
      <?php } ?>
      <?php if (!empty($projects_forbidden)) { ?>
        <div class="alert alert-danger"><strong>Forbidden project enabled:</strong>
          <?php print implode(', ', $projects_forbidden); ?></div>
      <?php } ?>
      <?php if (!empty($projects_discouraged)) { ?>
        <div class="alert alert-warning"><strong>Discouraged project enabled:</strong>
          <?php print implode(', ', $projects_discouraged); ?></div>
      <?php } ?>

      <h3>Updates</h3>
      <pre><code><?php print htmlspecialchars(getenv('updates')); ?></code></pre>

      <div class="panel-group" id="features">
        <?php foreach ($features as $feature) { ?>
          <div class="panel panel-danger">
            <div class="panel-heading"><h3 class="panel-title">
              <a data-toggle="collapse" data-parent="#features" href="#feature-<?php print htmlspecialchars($feature['name']); ?>"><strong>Overridden feature:</strong> <?php print htmlspecialchars($feature['name']); ?></a>
            </h3></div>
            <div id="feature-<?php print htmlspecialchars($feature['name']); ?>" class="panel-collapse collapse"><div class="panel-body">
              <pre><code><?php print htmlspecialchars($feature['diff']); ?></code></pre>
            </div></div>
          </div>
        <?php } ?>
      </div>

    </div>

    <script src="js/jquery-1.11.0.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
  </body>
</html>
