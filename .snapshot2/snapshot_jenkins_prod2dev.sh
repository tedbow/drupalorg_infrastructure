#!/bin/bash

set -uex

SCRIPTDIR="/usr/local/drupal-infrastructure"
SSHUSER="ec2"

PRODDB="drupal"
PRODDBSERBER="db6-reader-vip.drupal.org"
SANSERVER="140.211.169.84"
FSDEST="/mnt/storage/mysql/dump"

# ssh to prod db server rsync to destination
ssh ${SSHUSER}@${PRODDBSERBER} "${SCRIPTDIR}/snapshot2/snapshot_prod-rsync.sh ${PRODDB} ${SANSERVER} ${SCRIPTDIR}/snapshot2/ ${FSDEST}"
# ssh to stagindb import and modifiy for staging
ssh ${SSHUSER}@${SANSERVER} "${SCRIPTDIR}/snapshot2/snapshot_prod-import-dev.sh ${PRODDB} ${FSDEST} ${SSHUSER}"
