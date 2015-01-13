#/bin/bash

set -uex

SSHUSER="ec2"
SANSERVER="140.211.169.84"
SCRIPTDIR="/usr/local/drupal-infrastructure"
PRODDB="drupal"
DBXPORT="${PRODDB}_export"
SANTYPE="skeleton"
SANOUT="no-dump"

ssh ${SSHUSER}@${SANSERVER} "${SCRIPTDIR}/snaphot2/snapshot_san-export.sh ${PRODDB} ${DBEXPORT} ${SANTYPE} ${SANOUT}
