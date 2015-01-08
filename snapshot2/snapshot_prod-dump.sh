#!/bin/bash

set -uex

[ ! -f /etc/dbdump/conf ] && exit 1
source /etc/dbdump/conf

PRODDB="${1}"
DUMPDIR="${PRODDUMPDIR}/${PRODDB}"
[ ! -d "${DUMPDIR}/" ] && mkdir -p "${DUMPDIR}/"
rm -f ${DUMPDIR}/*
mysqldump ${PRODDB} --single-transaction --tab=${DUMPDIR}/

