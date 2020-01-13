#!/bin/bash
set -eux
STAGING_REPLICATION_PASSWORD=$1

gitlab-ctl start
gitlab-ctl stop sidekiq
gitlab-ctl stop geo-logcursor

# alertmanager & geo-postgresql are stopped by replicate-geo-database, but
# sometimes timeout. Give them a head start.
gitlab-ctl stop alertmanager
gitlab-ctl stop geo-postgresql

# refresh geo db
gitlab-ctl reconfigure
echo ${STAGING_REPLICATION_PASSWORD} | gitlab-ctl replicate-geo-database --no-wait --force --skip-backup --slot-name=staging_secondary --host=10.1.0.42
gitlab-ctl reconfigure
gitlab-ctl stop sidekiq
gitlab-ctl stop geo-logcursor
# this blows out some errors.
gitlab-rake geo:db:reset || true
gitlab-ctl reconfigure
gitlab-rake geo:db:refresh_foreign_tables
gitlab-rake geo:db:migrate
# turn on gitlab
gitlab-ctl start
# Blow away old gitlab database backups so they dont stack up forever
# TODO: investigate if any of the above rake commands can take a --skip-backup like command.
rm -rf /var/opt/gitlab/postgresql/data.*
