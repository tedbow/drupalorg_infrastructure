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
curl -k -s -v -g --request GET --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" https://gitlab.drupalcode.org/api/v4/application/settings

# Restart gitlab
sudo gitlab-ctl start unicorn
sudo gitlab-ctl start sidekiq



