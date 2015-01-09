##!/bin/bash
#
#set -uex
#
#SCRIPTDIR="/usr/local/drupal-infrastructure"
#SSHUSER="ec2"
#
#PRODDB=""
#PRODDBSERBER=""
#STAGINGDB=""
#STAGINGDBSERVER=""
#STAGINGWEBSERVER=""
#TARGETSITE=""
#
#
###Get name of current staging db
#REQUESTDBNAME=$(ssh ${STAGINGWEBSERVER} [ -f /var/www/${TARGETSITE}/altdb ]  && echo "${STAGINGDB}1" || echo "${STAGINGDB}")
#[ -z "${REQUESTDBNAME}" ] && exit 1
#
## ssh to prod db server rsync to destination
#ssh ${SSHUSER}@${PRODDBSERBER} "${SCRIPTDIR}/snapshot2/snapshot_prod-rsync.sh ${PRODDB} ${STAGINGDBSERVER} ${SCRIPTDIR}/snapshot2/"
## ssh to stagindb import and modifiy for staging
#ssh ${SSHUSER}@${STAGINGDBSERVER} "${SCRIPTDIR}/snapshot2/snapshot_prod-import-staging.sh ${PRODDB} ${REQUESTDBNAME}"
