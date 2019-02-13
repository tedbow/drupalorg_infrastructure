#!/bin/bash
set -eux
# This script is run after we restore a production snapshot to staging
GITLAB_BACKUP_FILE=$1
PRIVATE_TOKEN=$2
# Stop any running gitlab.
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq

# Clean up messes that gitlab made during any previous restore.
rm -rf /var/opt/gitlab/backups/repositories /var/opt/gitlab/backups/tmp /var/opt/gitlab/git-data/repositories/+gitaly || true

# Restore the backup on gitlabstg1
gitlab-rake gitlab:backup:restore force=yes BACKUP=${GITLAB_BACKUP_FILE%_gitlab_backup.tar} |tee -a backupoutput.txt
gitlab-ctl reconfigure
# Remove the backup file
rm -rf /var/opt/gitlab/backups/${GITLAB_BACKUP_FILE} || true

# Reconfigure the geo settings for staging urls.
gitlab-rails runner "eval(File.read '/usr/local/drupal-infrastructure/gitlab/geo-reconfigure.rb')"
GITLAB_HOST=gitlab.code-staging.devdrupal.org

# Reset the authorized_keys setting to use the db
curl -s -g --request PUT --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" https://${GITLAB_HOST}/api/v4/application/settings?authorized_keys_enabled=false

# Restart gitlab
gitlab-ctl start unicorn
gitlab-ctl start sidekiq
