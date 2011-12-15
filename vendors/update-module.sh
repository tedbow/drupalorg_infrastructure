# Exit immediately on uninitialized variable or error, and print each command.
set -uex

branch=${site}.drupal.org
[ ${site} = 'drupal.org' ] && branch=drupal.org
rm -rf ${branch}
bzr co /srv/bzr/${branch}/
cd ${branch}
bzr merge /srv/bzr/vendor/${module}/${vendor_version}
bzr commit -m "Automatic merge from ${module} ${vendor_version}/"
