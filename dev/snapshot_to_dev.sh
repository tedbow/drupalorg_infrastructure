#!/bin/bash
set -uex

SNAPSHOTPATH=/var/lib/docker/docker-images/

## Get the DB snapshots
rsync -vr --whole-file --password-file ~/util.rsync.pass  --exclude-from="./dev/db-exclusions.txt" --delete --delete-excluded "rsync://devmysql@dbutil.drupal.org/mysql-dev/*_database_snapshot.dev-*.image.tar.bz2" "${SNAPSHOTPATH}"

## Build the docker container
cd ${SNAPSHOTPATH}
/usr/local/drupal-infrastructure/docker/db-images/db-image-load.sh dev

rm -rf ${SNAPSHOTPATH}/*
