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
  'php',
  'ds_format',
), $projects);
$projects_discouraged = array_intersect(array(
  'views_ui',
), $projects);

$updates = array();
$header = array('project', 'installed', 'available', 'type');
foreach (explode("\n", getenv('updates')) as $line) {
  $updates[] = array_combine($header, explode(' ', $line));
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
      <?php // todo remove !== condition when all sites are on Git. ?>
      <?php if (getenv('version_available') && getenv('version') !== getenv('version_available')) { ?>
        <div class="panel panel-info">
          <div class="panel-heading"><h3 class="panel-title">Commits to deploy</h3></div>
          <div class="panel-body">
            <pre><code><?php print htmlspecialchars(getenv('version_available')); ?></code></pre>
          </div>
        </div>
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
      <table class="table">
        <tr><th>Project</th><th>Installed</th><th>Available</th></tr>
        <?php foreach ($updates as $update) { ?>
          <tr<?php if ($update['type'] === 'SECURITY-UPDATE-available') { print ' class="danger"'; } ?>>
            <td><?php print $update['project']; ?></td>
            <td><?php print $update['installed']; ?></td>
            <td><?php print $update['available']; ?></td>
          </tr>
        <?php } ?>
      </table>

      <h3>Logs</h3>
      <p>DB logs since <strong class="text-<?php print (getenv('log_earliest') < strtotime('-1 week')) ? 'info' : 'danger' ?>"><?php print gmdate('Y-m-d H:i:s', getenv('log_earliest')) ?></strong></p>
      <table class="table table-condensed">
        <tr><th class="text-right">#</th><th>Earliest</th><th>Latest</th><th>Message</th></tr>
        <?php
        $first = TRUE;
        $severities = array(
          3 => 'danger',
          4 => 'warning',
          5 => '',
        );
        foreach (file('log_php_summary.tsv', FILE_IGNORE_NEW_LINES) as $line) {
          if ($first) { // Skip header row.
            $first = FALSE;
            continue;
          }
          list($severity, $c, $earliest, $latest, $variables, $locations) = explode("\t", $line);
          if ((time() - $latest) < 60 * 60) {
            $latest_class = 'text-danger';
          }
          elseif ((time() - $latest) < 60 * 60 * 6) {
            $latest_class = 'text-warning';
          }
          else {
            $latest_class = '';
          }
          $variables = unserialize(str_replace(array('\n', '\\\\'), array("\n", '\\'), $variables)); ?>
            <tr class="<?php print $severities[$severity]; ?>">
              <td class="text-right"><?php print number_format($c); ?></td>
              <td class="text-nowrap"><?php if ($earliest != $latest) { ?>
                <small><?php print gmdate('Y-m-d', $earliest); ?></small><br><?php print gmdate('H:i:s', $earliest); ?>
              <?php } ?></td>
              <td class="text-nowrap <?php print $latest_class; ?>"><small><?php print gmdate('Y-m-d', $latest); ?></small><br><?php print gmdate('H:i:s', $latest); ?></td>
              <td><?php print nl2br(htmlspecialchars($variables['!message'])); ?><br>
                <code><?php print htmlspecialchars($variables['%function']); ?></code> at <code><?php print htmlspecialchars($variables['%file']); ?>:<?php print htmlspecialchars($variables['%line']); ?></code><br>
                <?php print implode(', ', explode(',', $locations); ?></td>
            </tr>
        <?php } ?>
      </table>

      <?php if ($features = getenv('features')) { ?>
        <div class="panel-group" id="features">
          <?php foreach (explode("\n", $features) as $feature) { ?>
            <div class="panel panel-danger">
              <div class="panel-heading"><h3 class="panel-title">
                <strong>Overridden feature:</strong> <?php print htmlspecialchars($feature); ?>
              </h3></div>
            </div>
          <?php } ?>
        </div>
      <?php } ?>
    </div>

    <script src="js/jquery-1.11.0.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
  </body>
</html>
<?php
// Exit with error if there is something wrong.
if (!empty($projects_missing)) {
  exit(1);
}
?>
