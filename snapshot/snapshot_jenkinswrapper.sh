#!/bin/sh
# Wrapper to work around passing Jenkins environment variables through SSH

export WORKSPACE=${1}
export JOB_NAME=${2}
export BUILD_NUMBER=${3}
[ "${8-}" ] && export db_host=${8}

# Make sure the WORKSPACE exists
mkdir -p ${WORKSPACE}


# Need to be in repository with the .sql files
cd /usr/local/drupal-infrastructure

# Snapshot/sanitize
/usr/local/drupal-infrastructure/snapshot/snapshot.sh ${4} ${5} ${6} ${7}
