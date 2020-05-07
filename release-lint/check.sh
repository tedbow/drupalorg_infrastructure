#!/bin/bash
{
  # Exit immediately on uninitialized variable or error, and print each command.
  set -uex -o noglob

  read -r -p 'Branches and/or tags to check, such as "8.9.x 8.9.0-beta2": ' -a labels

  diffarg='--brief'
  ftpdrupal='ftp.drupal.org'
  drupalcode='git.drupalcode.org'
  while getopts ":vs" opt; do
    case ${opt} in
      v )
        diffarg='-u'
        ;;
      s )
        ftpdrupal='drupal:drupal@www.staging.devdrupal.org'
        drupalcode='git.code-staging.devdrupal.org'
        ;;
      \? )
        echo "Usage: ${0} [-v]"
        exit 1
        ;;
    esac
  done

  tmpdir="$(mktemp -d)"
  cd "${tmpdir}"

  for label in "${labels[@]}"
  do
    mkdir "${label}" && pushd "${label}"
    mkdir 'git' 'tar'
    release="${label/%\.x/.x-dev}"

    # Get the tarball & repository.
    (
      curl --silent "https://${ftpdrupal}/files/projects/drupal-${release}.tar.gz" | tar x --directory 'tar' --strip-components 1
    ) &
    git -c 'advice.detachedHead=false' clone --quiet --branch "${label}" --depth 1 "https://${drupalcode}/project/drupal.git" 'git'
    wait

    # Compare them.
    diff -r "${diffarg}" --exclude='*.info.yml' 'git' 'tar' || true

    # Clean up.
    rm -rf 'git' 'tar'
    popd
  done

  rm -rv "${tmpdir}"

}
