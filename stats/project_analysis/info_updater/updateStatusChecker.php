#!/usr/bin/env php
<?php

use InfoUpdater\UpdateStatusXmlChecker;

require_once __DIR__ . '/vendor/autoload.php';
if (!isset($argv[1])) {
  throw new Exception("Provide file");
}
$checker = new UpdateStatusXmlChecker($argv[1]);
return $checker->runRector();
if ($checker->runRector()) {
  echo "yes";
}
else {
  echo "no";
}
