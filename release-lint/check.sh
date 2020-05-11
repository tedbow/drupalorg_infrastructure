#!/bin/bash
{
  # Exit immediately on uninitialized variable or error, and print each command.
  set -uex -o noglob

  diffarg='--brief'
  ftpdrupal='ftp.drupal.org'
  drupalcode='git.drupalcode.org'
  while getopts ":vs" opt; do
    case ${opt} in
      v )
        # -v for full diff.
        diffarg='-u'
        ;;
      s )
        # -s to use staging.
        ftpdrupal='drupal:drupal@www.staging.devdrupal.org'
        drupalcode='git.code-staging.devdrupal.org'
        ;;
      \? )
        echo "Usage: ${0} [-v] [-s]"
        exit 1
        ;;
    esac
  done
  shift $((OPTIND-1))

  tmpdir="$(mktemp -d)"
  cd "${tmpdir}"

  for label in "${@}"
  do
    mkdir "${label}" && pushd "${label}"
    mkdir 'git' 'tar'
    release="${label/%\.x/.x-dev}"

    # Get the tarball & repository.
    (
      curl --silent "https://${ftpdrupal}/files/projects/drupal-${release}.tar.gz?$(date +%s)" | tar x --directory 'tar' --strip-components 1
    ) &
    git -c 'advice.detachedHead=false' clone --quiet --branch "${label}" --depth 1 "https://${drupalcode}/project/drupal.git" 'git'
    wait

    # Compare them.
    if [[ "${label}" =~ ^7\..* ]]; then
      exclude='*.info'
    else
      exclude='*.info.yml'
    fi
    diff -r "${diffarg}" --exclude="${exclude}" 'git' 'tar' || true

    # Clean up.
    rm -rf 'git' 'tar'
    popd
  done

  rm -rv "${tmpdir}"

}
