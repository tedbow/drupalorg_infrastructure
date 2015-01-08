#!/bin/bash

set -uex
PRODDB="$1"
DUMPDIR="$2/${PRODDB}"
[ ! -d "${DUMPDIR}/" ] && mkdir -p "${DUMPDIR}/"
rm -f ${DUMPDIR}/*
mysqldump ${PRODDB} --single-transaction --tab=${DUMPDIR}/

