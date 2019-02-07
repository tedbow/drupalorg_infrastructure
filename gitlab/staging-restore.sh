#!/bin/bash
# This script is run after we restore a production snapshot to staging

# Stop any running gitlab.
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq

# Clean up messes that gitlab made during any previous restore.
rm -rf /var/opt/gitlab/backups/repositories /var/opt/gitlab/backups/tmp /var/opt/gitlab/git-data/repositories/+gitaly || true

# Restore the backup on gitlabstg1
gitlab-rake gitlab:backup:restore force=yes BACKUP=$1 |tee -a backupoutput.txt

# Reconfigure the geo settings for staging urls.
gitlab-rails runner "eval(File.read '/usr/local/drupal-infrastructure/gitlab/geo-reconfigure.rb')"
GITLAB_URL=gitlab.drupalcode.org

# Reset the authorized_keys setting to use the db
curl -s -g --request PUT --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" https://${GITLAB_URL}/api/v4/application/settings?authorized_keys_enabled=false

# Restart gitlab
gitlab-ctl start unicorn
gitlab-ctl start sidekiq
