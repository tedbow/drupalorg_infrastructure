#!/bin/bash
###snapshot_prod2dev.sh <PRODDB> <PRODDBSERBER> <SANITIAZATIONSERVER>
set -uex

PRODDB="${1}"
PRODDBSERBER="${2}"
SANSERVER="${3}"
SSHUSER="ec2"

# ssh to prod db server rsync to destination
ssh ${SSHUSER}@${PRODDBSERBER} "${SCRIPTDIR}/snapshot2/snapshot_prod-rsync.sh ${PRODDB} ${SANSERVER} ${SCRIPTDIR}/snapshot2/"
# ssh to sanserver and run import script
ssh ${SSHUSER}@${SANSERVER} "/mnt/storage/git-repos/infrastructure/snapshot2/import.sh"


