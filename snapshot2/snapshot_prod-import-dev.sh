#!/bin/bash
set -uex

sudo chown -R ${SSHUSER}:${SSHUSER} ${TMPSTORAGE}/mysql/current-raw/

docker run -t --rm \
  -v ${TMPSTORAGE}/mysql/current-raw/:/var/lib/mysql/ \
  -v ${INFRAREPO}/:/media/infrastructure/ \
  ${DOCKERCON} \
  /media/infrastructure/snapshot2/raw-import-con.sh ${NTHREADS}
sync

