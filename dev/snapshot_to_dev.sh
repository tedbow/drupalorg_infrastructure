#!/bin/bash
set -uex

SNAPSHOTPATH=/var/dumps/dev/

## Get the DB snapshots
rsync -vr --whole-file --password-file ~/util.rsync.pass --delete "rsync://devmysql@dbutil.drupalsystems.org/mysql-dev/*_database_snapshot.dev-*.image.tar.bz2" "${SNAPSHOTPATH}"

## Build the docker container
cd ${SNAPSHOTPATH}
/usr/local/drupal-infrastructure/docker/db-images/db-image-load.sh dev

rm -rf ${SNAPSHOTPATH}/*
