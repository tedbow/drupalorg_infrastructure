# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Determine the vendor version by stripping the last '.' and all following
# characters. For example, '7.x-3.x-dev' -> '7.x-3'.
vendor_version=$(echo "${version}" | sed -e 's/\.[^.]*$//')

# Vendor repository location.
vendor="/srv/bzr/vendor/${project}/${vendor_version}"

# Import latest release tarball from Drupal.org into vendor branch.
./vendors/d.o-tar-to-bzr.php "${project}" "${version}"

# Optionally merge to a site.
if [ "${site}" != "- do not merge to a site -" ]; then
  # Clear out any old checkout and make a fresh one.
  rm -rf "${WORKSPACE}/${site}"
  bzr co "/srv/bzr/${site}/" "${WORKSPACE}/${site}"
  cd "${WORKSPACE}/${site}"

  if [ $(ls -d sites/all/{modules,themes,libraries}/${project} 2> /dev/null | wc -l) = 1 ] || [ "${project}" = "drupal" ]; then
    # If the project already exists, merge in the update.
    bzr merge ${vendor}
    bzr commit -m "Automatic merge from ${project} ${vendor_version}. ${message-}"
  else
    # Otherwise, join in the project.
    bzr checkout ${vendor} tmp
    if grep -q "^engine" tmp/*.info; then
      location="sites/all/themes/${project}"
    elif grep -q "^engine" $(find tmp -name '*.info' | head -n 1); then
      location="sites/all/themes/${project}"
    else
      location="sites/all/modules/${project}"
    fi
    mv tmp ${location}
    bzr join ${location}
    bzr commit -m "Automatic join from ${project} ${vendor_version}. ${message-}"
  fi

  # Clean up workspace
  rm -rf "${WORKSPACE}/${site}"
fi
