#!/bin/bash
set -uex
SSHTARGET=$1
STORAGE=$2
BINVARS=$3
time sudo innobackupex ${BINVARS} --user='root' --password='88*<hwUz$@' --stream=xbstream \
  /var/tmp/backup/b1 | ssh -i /home/ec2/.ssh/id_rsa ec2@${SSHTARGET} "xbstream -x -C ${STORAGE}/mysql/current-raw/"
