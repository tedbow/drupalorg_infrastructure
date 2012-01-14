# Exit immediately on uninitialized variable or error, and print each command.
set -uex

branch="${site}.drupal.org"
[ ${site} = "drupal.org" ] && branch="drupal.org"
vendor="/srv/bzr/vendor/${module}/${vendor_version}"
location="sites/all/modules/${module}"

rm -rf ${branch}
bzr co /srv/bzr/${branch}/
cd ${branch}

if [ -d ${location} ]; then
  bzr merge ${vendor}
  bzr commit -m "Automatic merge from ${module} ${vendor_version}. ${message-}"
else
  bzr checkout ${vendor} ${location}
  bzr join ${location}
  bzr commit -m "Automatic join from ${module} ${vendor_version}. ${message-}"
fi
