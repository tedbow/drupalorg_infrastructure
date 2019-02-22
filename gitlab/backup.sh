#!/bin/bash
set -eux

# Ensure we've got a clean log
rm /tmp/backupoutput.log || true
# Have gitlab take a backup
sudo /opt/gitlab/bin/gitlab-rake gitlab:backup:create | tee -a /tmp/backupoutput.log
# Transfer the backup to staging.
GITLAB_BACKUP=`grep 'Creating backup archive:' /tmp/backupoutput.log |awk '{print $4}'`

sudo rsync -avPz /var/opt/gitlab/backups/${GITLAB_BACKUP} gitlabstg1.drupal.bak::backups
