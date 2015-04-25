#!/bin/sh
# Wrapper to work around passing Jenkins environment variables through SSH

export JOB_NAME=${1}
export BUILD_NUMBER=${2}
# @TODO: add this when exporting a db_host is supported
#[ "${5-}" ] && export db_host=${5}

# Need to be in repository with password.py
cd /usr/local/drupal-infrastructure

# Snapshot/sanitize
./sanitize/sanitize.sh ${3} ${4}
