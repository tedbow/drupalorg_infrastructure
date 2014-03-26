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
    <p><span class="badge"><?php print getenv('version') ?></span> is deployed.</p>
    <?php if (getenv('version') !== getenv('version_available')) { ?>
      <div class="alert alert-info"><?php print getenv('version_available') ?> is available.</div>
    <?php } ?>

    <script src="js/jquery-1.11.0.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
  </body>
</html>
