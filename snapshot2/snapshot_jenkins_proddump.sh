##!/bin/bash
#
#set -uex
#
###Copy into jenkins, remove first comment and add prod db name
#SSHUSER="ec2"
#PRODBSERVER="db6-reader-vip.drupal.org"
#SCRIPTDIR="/usr/local/drupal-infrastructure"
#PRODDB=""
#
###ssh to prod db server mysql dump
#ssh ${SSHUSER}@${PRODBSERVER} "${SCRIPTDIR}/snapshot2/snapshot_prod-dump.sh ${PRODDB}"
