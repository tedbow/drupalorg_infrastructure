#!/bin/bash
# This script is run after we restore a production snapshot to staging

# Stop any running gitlab.
sudo gitlab-ctl stop unicorn
sudo gitlab-ctl stop sidekiq

# Restore the backup on gitlabstg1
# XXX gitlab-rake gitlab:backup:restore BACKUP=$1
echo $1
echo $2

# Reconfigure the geo settings for staging urls.
# XXX gitlab-rails runner "eval(File.read '/usr/local/drupal-infrastructure/gitlab/geo-reconfigure.rb')"
GITLAB_URL=gitlab.drupalcode.org

# Reset the authorized_keys setting to use the db
# XXX curl -s -g --request PUT --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" "https://${GITLAB_URL}/api/v4/application/settings?authorized_keys_enabled=false

# Restart gitlab
gitlab-ctl start unicorn
gitlab-ctl start sidekiq



