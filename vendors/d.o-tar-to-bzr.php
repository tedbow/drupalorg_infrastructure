#!/usr/bin/env php
<?php

/**
 * @file
 * Script to take a d.o release tarball and import into bzr vendor.
 *
 * Usage: d.o-tar-to-bzr.php [project_shortname] [version]
 *
 * Requirements: bzr
 * 
 * @author Derek Wright (http://drupal.org/user/46549)
 */

// ------------------------------------------------------------
// Configuration
// ------------------------------------------------------------

$tmp_dir = '/tmp/tarball-import';

$package_release_nodes = '/bin/nice -n 10 /usr/bin/php /var/www/drupal.org/project/scripts/package-release-nodes.php';

$package_root = '/var/www/drupal.org/htdocs/files/projects';

// If you want to run this remotely, uncomment the following:
//$bzr_root = 'bzr+ssh://util.drupal.org';

// ------------------------------------------------------------
// Sanity checks
// ------------------------------------------------------------

$project = $argv[1];
$version = $argv[2];

$now = gmdate('YmdHi');

if (empty($project) || empty($version)) {
  echo "Usage: $argv[0] [project_name] [version]\n";
  exit(1);
}

if (getenv('WORKSPACE') === FALSE) {
  $tmp_dir .= "-$project-$now";
}
else {
  $tmp_dir = getenv('WORKSPACE');
}

if (!is_dir($tmp_dir) && !mkdir($tmp_dir, 0777, TRUE)) {
  echo "ERROR: temp directory $tmp_dir does not exist and can't created.\n";
  exit(2);
}

if (!chdir($tmp_dir)) {
  echo "ERROR: Can not chdir($tmp_dir).\n";
  exit(3);
}

$release_type = preg_match('/^.*\d.x-dev.*$/', $version) ? 'branch' : 'tag';
echo "Starting to import $project from $release_type: $version (using $tmp_dir)\n";

// ------------------------------------------------------------
// Real work
// ------------------------------------------------------------

// If we're importing from a tag, see if the tarball already exists.
$tarball_name = "$project-$version.tar.gz";
$tarball_path = "$package_root/$tarball_name";
echo "Looking for $tarball_path\n";
$have_tarball = $release_type == 'tag' && file_exists($tarball_path);

if (!$have_tarball) {
  _d_o_passthru("$package_release_nodes $release_type $project");
  if (!file_exists($tarball_path)) {
    echo "ERROR: $tarball_path does not exist after running package-release-nodes\n";
    exit(4);
  }
}

_d_o_cleanup($project);

// Extract the tarball.
_d_o_passthru('tar -zxvf ' . $tarball_path);
if (file_exists($project . '-' . $version)) {
  // Core extracts with the version string.
  _d_o_passthru('mv ' . $project . '-' . $version . ' ' . $project);
}
// Contrib tarballs should always extract into a directory named via the
// project shortname, so make sure that's there.
if (!file_exists($project)) {
  echo "ERROR: $project directory does not exist after extracting tarball\n";
  exit(5);
}

// Grab the first 5 chars of the version so we've got "6.x-2" for the vendor
// branch name.
$major_id = substr($version, 0, strrpos($version, '.'));

// bzr+ssh://util.drupal.org/srv/bzr/vendor/views/6.x-2
$bzr_url = isset($bzr_root) ? $bzr_root : '';
$bzr_url .= "/srv/bzr/vendor/$bzr_root/$project/$major_id";

passthru("bzr init --create-prefix $bzr_url");
_d_o_passthru("bzr checkout $bzr_url bzr-vendor");

// Check for differences
$rval = 0;
passthru("diff -rqI'^\(datestamp = \|; Information added by d.o-cvs-to-bzr\)' -x .bzr bzr-vendor $project", $rval);
if ($rval == 0) {
  print "No changes, exiting.\n";
  _d_o_cleanup($project);
  exit(0);
}

// Import to vendor checkout.
_d_o_passthru("bzr import $project bzr-vendor");
chdir('bzr-vendor');
_d_o_passthru('bzr commit -m"Import from tarball: ' . $tarball_name .'"');
chdir('..');

_d_o_cleanup($project);


/**
 * Clean up workspace.
 */
function _d_o_cleanup($project) {
  _d_o_passthru('rm -rf bzr-vendor ' . $project);
}

/**
 * Helper function for outputting command and output, and exiting on failiure.
 */
function _d_o_passthru($cmd) {
  $rval = 0;
  echo '+ ' . $cmd . "\n";
  passthru($cmd, $rval);
  if ($rval != 0) {
    exit($rval);
  }
}
