#!/bin/bash
set -eux
STAGING_REPLICATION_PASSWORD=$1

gitlab-ctl start
gitlab-ctl stop sidekiq
gitlab-ctl stop geo-logcursor
# refresh geo db
echo ${STAGING_REPLICATION_PASSWORD} | gitlab-ctl replicate-geo-database --no-wait --force --skip-backup --slot-name=staging_secondary --host=10.1.0.42
gitlab-ctl reconfigure
gitlab-ctl stop sidekiq
gitlab-ctl stop geo-logcursor
gitlab-rake geo:db:reset
gitlab-ctl reconfigure
gitlab-rake geo:db:refresh_foreign_tables
gitlab-rake geo:db:migrate


# turn on gitlab
sudo gitlab-ctl start
