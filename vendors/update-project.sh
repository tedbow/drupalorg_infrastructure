# Exit immediately on uninitialized variable or error, and print each command.
set -uex

vendor="/srv/bzr/vendor/${project}/${vendor_version}"

rm -rf ${site}
bzr co /srv/bzr/${site}/
cd ${site}

if [ $(ls -d sites/all/{modules,themes}/${project} 2> /dev/null | wc -l) = 1 ]; then
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
