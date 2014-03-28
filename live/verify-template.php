<!DOCTYPE html>
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

    </div>

    <script src="js/jquery-1.11.0.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
  </body>
</html>
