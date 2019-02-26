#!/bin/bash
set -eux

# Ensure we've got a clean log
rm /tmp/backupoutput.log || true
# Have gitlab take a backup
sudo /opt/gitlab/bin/gitlab-rake gitlab:backup:create | tee -a /tmp/backupoutput.log
