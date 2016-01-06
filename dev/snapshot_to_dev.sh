#!/bin/bash
set -uex

SNAPSHOTPATH=/var/www/docker-images/
mkdir -p ${SNAPSHOTPATH}

## Get the DB snapshots
rsync -vr --password-file ~/util.rsync.pass  --exclude-from="./dev/db-exclusions.txt" --delete --delete-excluded "rsync://devmysql@dbutil.drupal.org/mysql-dev/*_database_snapshot.dev-*.image.tar.bz2" "${SNAPSHOTPATH}"

## Build the docker container
cd ${SNAPSHOTPATH}
/usr/local/drupal-infrastructure/docker/db-images/db-image-load.sh dev
