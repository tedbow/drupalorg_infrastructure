#!/bin/bash

### Get the DB snapshots
rsync -vr --copy-links --password-file ~/util.rsync.pass  --exclude-from="./dev/db-exclusions.txt" --delete --delete-excluded "rsync://devmysql@dbutil.drupal.org/mysql-dev/*_database_snapshot.dev-current.sql.bz2" "${WORKSPACE}"

### Build the docker container
cd ${WORKSPACE}
/usr/local/dev_infrastructure_containers/build.sh
