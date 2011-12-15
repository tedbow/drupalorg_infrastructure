#!/usr/bin/env php
<?php
// $Id$

/**
 * @file
 * Script to take a d.o release tarball and import into bzr vendor.
 *
 * Usage: d.o-tar-to-bzr.php [project_shortname] [version] [working_dir]
 *
 * Requirements: bzr
 * 
 * @author Derek Wright (http://drupal.org/user/46549)
 *
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
if (!empty($argv[3])) {
  $cwd = $argv[3];
}

$now = gmdate('YmdHi');

if (empty($project) || empty($version)) {
  echo "Usage: $argv[0] [project_name] [version] [working_dir]\n";
  exit(1);
}

$release_type = preg_match('/^.*\d.x-dev.*$/', $version) ? 'branch' : 'tag';
echo "Starting to import $project from $release_type: $version\n";

if ($release_type == 'tag') {
  $vendor_tag = $version;
}
else {
  // They specified a branch, so we append a UTC timestamp to the end to
  // ensure uniqueness.
  $vendor_tag = $version . '-' . $now;
}

echo "Using vendor_tag: $vendor_tag for $project\n";

empty($cwd) ? $tmp_dir .= "-$project-$now" : $tmp_dir = $cwd;

if (!is_dir($tmp_dir) && !mkdir($tmp_dir, 0777, TRUE)) {
  echo "ERROR: temp directory $tmp_dir does not exist and can't created.\n";
  exit(2);
}

if (!chdir($tmp_dir)) {
  echo "ERROR: Can not chdir($tmp_dir).\n";
  exit(3);
}

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

// Extract the tarball.
_d_o_passthru("tar -zxvf $tarball_path");
// Contrib tarballs should always extract into a directory named via the
// project shortname, so make sure that's there.
if (!file_exists($project)) {
  echo "ERROR: $project directory does not exist after extracting tarball\n";
  exit(5);
}

// Prune the LICENSE.txt file
@unlink("$project/LICENSE.txt");

// Grab the first 5 chars of the version so we've got "6.x-2" for the vendor
// branch name.
$major_id = substr($version, 0, 5);

// bzr+ssh://util.drupal.org/srv/bzr/vendor/views/6.x-2
$bzr_url = isset($bzr_root) ? $bzr_root : '';
$bzr_url .= "/srv/bzr/vendor/$bzr_root/$project/$major_id";

passthru("bzr init --create-prefix $bzr_url");
_d_o_passthru("rm -rf bzr-vendor");
_d_o_passthru("bzr checkout $bzr_url bzr-vendor");

// Check for differences
$rval = 0;
passthru("diff -rqI'^\(datestamp = \|; Information added by d.o-cvs-to-bzr\)' -x .bzr bzr-vendor $project", $rval);
if ($rval == 0) {
  print "No changes, exiting.\n";
  exit(0);
}

chdir('bzr-vendor');
_d_o_passthru('rm -r *');
_d_o_passthru('bzr import ' . $project);
_d_o_passthru('bzr commit -m"Import from tarball: ' . $tarball_name .'"');

// ------------------------------------------------------------
// Helper functions
// ------------------------------------------------------------

/**
 * 
 */
function _d_o_passthru($cmd) {
  $rval = 0;
  echo '+ ' . $cmd . "\n";
  passthru($cmd, $rval);
  if ($rval != 0) {
    exit($rval);
  }
}
