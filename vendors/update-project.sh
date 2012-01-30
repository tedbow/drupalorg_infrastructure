# Exit immediately on uninitialized variable or error, and print each command.
set -uex

branch="${site}.drupal.org"
[ ${site} = "drupal.org" ] && branch="drupal.org"
vendor="/srv/bzr/vendor/${project}/${vendor_version}"

rm -rf ${branch}
bzr co /srv/bzr/${branch}/
cd ${branch}

if [ -d sites/all/{modules,themes}/${project} ]; then
  bzr merge ${vendor}
  bzr commit -m "Automatic merge from ${project} ${vendor_version}. ${message-}"
else
  bzr checkout ${vendor} tmp
  if grep -q "^engine" tmp/*.info; then
    location="sites/all/themes/${project}"
  else
    location="sites/all/modules/${project}"
  fi
  mv tmp ${location}
  bzr join ${location}
  bzr commit -m "Automatic join from ${project} ${vendor_version}. ${message-}"
fi
