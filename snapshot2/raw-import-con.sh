#!/bin/bash
set -uex
cd /var/lib/mysql
NTHREADS=$1
innobackupex --decompress --parallel ${NTHREADS} .
innobackupex --apply-log .
chown -R mysql:mysql /var/lib/mysql
service mysql start
service mysql stop
exit

