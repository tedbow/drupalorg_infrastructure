#!/bin/bash
set -eux

# Ensure we've got a clean log
rm /tmp/backupoutput.log
# Have gitlab take a backup
sudo /opt/gitlab/bin/gitlab-rake gitlab:backup:create | tee -a /tmp/backupoutput.log
# Transfer the backup to staging.
sudo rsync -avPz /var/opt/gitlab/backups/${GITLAB_BACKUP} gitlabstg1.drupal.bak::backups
