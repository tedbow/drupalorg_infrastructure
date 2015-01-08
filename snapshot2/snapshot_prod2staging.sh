#!/bin/bash

set -uex

STAGINGDBSERVER="${1}"
TARGETSITE="${2}"
PRODDB="${3}"
STAGINGDB="${4}"
STAGINGWEBSERVER="${5}"


# get current working directory
export CWD=$(dirname "${BASH_SOURCE[0]}")
[ ! -f ${CWD}/conf ] && exit 1
source ${CWD}/conf
# ssh to prod db server mysql dump
${CWD}/snapshot_prod-dump.sh ${PRODDB} ${PRODDUMPDIR}
# ssh to prod db server rsync to destination
${CWD}/snapshot_prod-rsync.sh ${PRODDB} ${PRODDUMPDIR} ${STAGINGDEST} ${SSHUSER}
# ssh to stagindb import and modifiy for staging
REQUESTDBNAME=$(ssh ${STAGINGWEBSERVER} [ -f /var/www/${TARGETSITE}/altdb ]  && echo "${STAGINGDB}1" || echo "${STAGINGDB}")
${CWD}/snapshot_prod-import-staging.sh ${PRODDB} ${REQUESTDBNAME}
