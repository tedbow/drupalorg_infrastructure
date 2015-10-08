#!/bin/bash

### Get the DB snapshots
rsync -v --copy-links --password-file ~/util.rsync.pass "rsync://devmysql@dbutil.drupal.org/mysql-dev/*_database_snapshot.dev-current.sql.bz2" "${WORKSPACE}"

### Build the docker container
/usr/local/dev_infrastructure_containers/build.sh
