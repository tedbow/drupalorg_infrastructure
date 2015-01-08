#!/bin/bash

###snapshot2/snapshot_prod2staging.sh <PRODDB> <PRODDBSERBER> <STAGINGDB> <STAGINGDBSERVER> <STAGINGWEBSERVER> <TARGETSITE>

set -uex

PRODDB="${1}"
PRODDBSERBER="${2}"
STAGINGDB="${3}"
STAGINGDBSERVER="${4}"
STAGINGWEBSERVER="${5}"
TARGETSITE="${6}"

SSHUSER="ec2"

###Get name of current staging db
REQUESTDBNAME=$(ssh ${STAGINGWEBSERVER} [ -f /var/www/${TARGETSITE}/altdb ]  && echo "${STAGINGDB}1" || echo "${STAGINGDB}")
[ -z "${REQUESTDBNAME}" ] && exit 1

# ssh to prod db server rsync to destination
ssh ${SSHUSER}@${PRODDBSERBER} "${SCRIPTDIR}/snapshot2/snapshot_prod-rsync.sh ${PRODDB} ${SSHSTAGING} ${SCRIPTDIR}/snapshot2/"
# ssh to stagindb import and modifiy for staging
ssh ${SSHUSER}@${STAGINGDBSERVER} "${SCRIPTDIR}/snapshot2/snapshot_prod-import-staging.sh ${PRODDB} ${REQUESTDBNAME}"
