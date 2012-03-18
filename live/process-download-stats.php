#!/usr/bin/php
<?php
// $Id$

/**
 * @file
 * Generate drupal.org download stats.
 *
 * @author Brandon Bergren (http://drupal.org/user/53081)
 */


define('DRUPAL_ROOT', '/var/www/drupal.org/htdocs/');
define('SITE_NAME', 'drupal.org');
define('STATS_GLOB', '/var/log/DROP/drupal-awstats-data/awstats*.ftp.drupal.org.txt');

$scriptpath = realpath(dirname($_SERVER['SCRIPT_FILENAME']));

// First of all, ensure we are being run from the command line.
if (php_sapi_name() != 'cli') {
  die('This script is designed to run via the command line.');
}

// Safety harness off.
ini_set('memory_limit', '-1');

// Check if all required variables are defined.
$vars = array(
  'DRUPAL_ROOT' => DRUPAL_ROOT,
  'SITE_NAME' => SITE_NAME,
  'STATS_GLOB' => STATS_GLOB,
);
$fatal_err = FALSE;
foreach ($vars as $name => $val) {
  if (empty($val)) {
    print "ERROR: \"$name\" constant not defined, aborting\n";
    $fatal_err = TRUE;
  }
}
if ($fatal_err) {
  exit(1);
}

$script_name = $argv[0];

// Setup variables for Drupal bootstrap
$_SERVER['HTTP_HOST'] = SITE_NAME;
$_SERVER['REMOTE_ADDR'] = '127.0.0.1';
$_SERVER['REQUEST_URI'] = '/' . $script_name;
$_SERVER['SCRIPT_NAME'] = '/' . $script_name;
$_SERVER['PHP_SELF'] = '/' . $script_name;
$_SERVER['SCRIPT_FILENAME'] = $_SERVER['PWD'] .'/'. $script_name;
$_SERVER['PATH_TRANSLATED'] = $_SERVER['SCRIPT_FILENAME'];

if (!chdir(DRUPAL_ROOT)) {
  print "ERROR: Can't chdir(DRUPAL_ROOT), aborting.\n";
  exit(1);
}
// Make sure our umask is sane for generating directories and files.
umask(022);

require_once 'includes/bootstrap.inc';

drupal_bootstrap(DRUPAL_BOOTSTRAP_FULL);

$now = time();

$map = array();
$pcmap = array();
$result = db_query('SELECT f.fid, f.filepath, n.pid, n.version_api_tid FROM {files} f INNER JOIN {project_release_file} r ON f.fid = r.fid INNER JOIN {project_release_nodes} n ON r.nid = n.nid');
while ($row = db_fetch_object($result)) {
  $map[$row->filepath] = $row->fid;
  $pcmap[$row->filepath] = array($row->pid, !empty($row->version_api_tid) ? $row->version_api_tid : -1);
}

// @@@dehardcode
$result = db_query('SELECT tid, name FROM {term_data} WHERE vid = %d', 6);
$coremap = array();
while ($row = db_fetch_object($result)) {
  $coremap[$row->tid] = $row->name;
}
$coremap[-1] = 'Unknown';



$files = glob(STATS_GLOB);
$globalcounts = array();
$mcounts = array();
foreach ($files as $file) {
  $month = array();
  preg_match('/awstats(\d{2})(\d{4})/', $file, $month);
  $month = "$month[2]$month[1]";

  $handle = fopen($file, 'r');
  while ($line = fgets($handle)) {
    if ('BEGIN_SIDER ' == substr($line, 0, 12)) {
      break;
    }
  }
  $tcount = (int) substr($line, 12);
  $count = 0;
  while ($count < $tcount) {
    $line = fgets($handle);
    $arr = explode(' ', substr($line, 1));
    $globalcounts[$arr[0]] += (int) $arr[1];
    $curr = $pcmap[$arr[0]];
    $mcounts[$curr[0]][$month][$curr[1]] += (int) $arr[1];
    $count++;
  }
  $line = fgets($handle);
  fclose($handle);
  if ($line != "END_SIDER\n") {
    print "ERROR: END_SIDER was not where we expected it?";
print 'XX'. $line .'XX';
    exit(1);
  }
  db_query('SELECT 1'); // Ping the database to keep our connection alive.
print_r("$file \n Tally so far: ". $globalcounts['files/projects/drupal-6.17.tar.gz'] . "\n");
}

//print_r($corecounts);
//exit();

$conn = new Mongo();
$m = $conn->selectDB("download-statistics");
$coll = $m->selectCollection('data');
$coll->remove();
foreach ($mcounts as $project => $months) {
  ksort($months);
  $data = array();
  foreach ($months as $month => $cores) {
    foreach ($cores as $core => $downloads) {
      $data[$month][$coremap[$core]] = $downloads;
    }
    ksort($data[$month]);
  }
  if ($project == 3060) {
//    debug_zval_dump($data);
  }
  $coll->insert(array('pid' => (int)$project, 'downloads' => $data));
}

/*
$conn = new Mongo("localhost:27027");
$m = $conn->selectDB("download-statistics");
$m->authenticate("stats_runner", "iusadyfm9");
$coll = $m->selectCollection('data');
$coll->remove();
foreach ($mcounts as $project => $months) {
  ksort($months);
  $data = array();
  foreach ($months as $month => $cores) {
    foreach ($cores as $core => $downloads) {
      $data[$month][$coremap[$core]] = $downloads;
    }
    ksort($data[$month]);
  }
  if ($project == 3060) {
//    debug_zval_dump($data);
  }
  $coll->insert(array('pid' => (int)$project, 'downloads' => $data));
}
*/

print "Hold onto yer hats!\n";
foreach ($map as $k => $v) {
  if ($globalcounts[$k]) {
    db_query('UPDATE {project_release_file} SET downloads = %d WHERE fid = %d', $globalcounts[$k], $v);
  }
}
print "Whew!\n";

echo "Max PHP: ". memory_get_peak_usage() ."\n";
echo "Max Real: ". memory_get_peak_usage(TRUE) ."\n";

// Done.
exit();
