#!/bin/bash

set -uex

SCRIPTDIR="/usr/local/drupal-infrastructure"
SSHUSER="ec2"

PRODDB="drupal"
PRODDBSERBER="db6-reader-vip.drupal.org"
SANSERVER="stagingdb1.drupal.org"
FSDEST="/mnt/storage/mysq/dump"

# ssh to prod db server rsync to destination
ssh ${SSHUSER}@${PRODDBSERBER} "${SCRIPTDIR}/snapshot2/snapshot_prod-rsync.sh ${PRODDB} ${SANSERVER} ${SCRIPTDIR}/snapshot2 ${FSDEST}"
# ssh to stagindb import and modifiy for staging
ssh ${SSHUSER}@${STAGINGDBSERVER} "${SCRIPTDIR}/snapshot2/snapshot_prod-import-dev.sh ${PRODDB} ${FSDEST} ${SSHUSER}"
