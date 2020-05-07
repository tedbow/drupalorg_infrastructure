#!/bin/bash
{
  # Exit immediately on uninitialized variable or error, and print each command.
  set -uex -o noglob

  read -r -p 'Branches and/or tags to check, such as "8.9.x 8.9.0-beta2": ' -a labels

  diffarg='--brief'
  while getopts ":v" opt; do
    case ${opt} in
      v )
        diffarg='-u'
        ;;
      \? )
        echo "Usage: ${0} [-v] [-t]"
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
      curl --silent -O "https://ftp.drupal.org/files/projects/drupal-${release}.tar.gz"
      tar xf "drupal-${release}.tar.gz" --directory 'tar' --strip-components 1
    ) &
    git -c 'advice.detachedHead=false' clone --quiet --branch "${label}" --depth 1 https://git.drupalcode.org/project/drupal.git 'git'
    wait

    # Compare them.
    diff -r "${diffarg}" --exclude='*.info.yml' 'git' 'tar' || true

    # Clean up.
    rm -rf 'git' 'tar'
    popd
  done

  rm -rv "${tmpdir}"

}
