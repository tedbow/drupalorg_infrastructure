#!/bin/bash

set -uex
### snapshot-keep-only-x.sh <number to keep> <dir to clean up> <snapshot type>
KEEP="$((${1} + 1))"
DIR="${2}"
SSTYPE="${3}"
cd ${DIR} && ls | grep "${SSTYPE}" | sort | uniq -u | tail -n +${KEEP} | while read TBDDIR;
do
  sudo btrfs subvolume delete ${TBDDIR}
done
