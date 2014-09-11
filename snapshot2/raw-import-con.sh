#!/bin/bash
set -uex

cd /var/lib/mysql
innobackupex --decompress --parallel 8 .
innobackupex --apply-log .
chown -R mysql:mysql /var/lib/mysql
service mysql start
service mysql stop
exit

