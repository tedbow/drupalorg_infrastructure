#!/bin/bash
set -eux

# Have gitlab take a backup
rm /tmp/backupoutput.log
sudo /opt/gitlab/bin/gitlab-rake gitlab:backup:create | tee -a /tmp/backupoutput.log
GITLAB_BACKUP=`grep 'Creating backup archive:' /tmp/backupoutput.log |awk '{print $4}'`
echo ${GITLAB_BACKUP%_gitlab_backup.tar}

sudo rsync -avPz /var/opt/gitlab/backups/${GITLAB_BACKUP} gitlabstg1.drupal.bak::backups
