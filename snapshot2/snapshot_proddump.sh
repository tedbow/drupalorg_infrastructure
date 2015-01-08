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
