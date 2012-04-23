#!/bin/bash

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

function snapshot {
  [ -f "snapshot/common${suffix}.sql" ] && mysql -o ${tmp_args} < "snapshot/common${suffix}.sql"
  [ -f "snapshot/common-force${suffix}.sql" ] && mysql -f -o ${tmp_args} < "snapshot/common-force${suffix}.sql"

  [ ! -f "snapshot/${sanitization}${suffix}.sql" ] && return
  mysql -o ${tmp_args} < "snapshot/${sanitization}${suffix}.sql"

  mysqldump --single-transaction ${tmp_args} | gzip > "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}-in-progress.sql.gz"
  mv -v "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}-in-progress.sql.gz" "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}.sql.gz"
  ln -sfv "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}.sql.gz" "/var/dumps/mysql/${JOB_NAME}${suffix}-current.sql.gz"

  old_snapshots=$(ls -t /var/dumps/mysql/${JOB_NAME}${suffix}-[0-9]*.sql.gz | tail -n +2)
  if [ -n "${old_snapshots}" ]; then
    rm -v ${old_snapshots}
  fi
}

function clear_tmp {
  echo "DROP DATABASE ${tmp_db}; CREATE DATABASE ${tmp_db};" | mysql ${tmp_args}
}

# Configure credentials
db_name=$1
db_user=$2
db_pass=$3
[ "${sanitization-}" ] || sanitization=${db_name}
[ "${db_host-}" ] || db_host=db3-vip.drupal.org

tmp_db=drupal_sanitize
tmp_user=sanitize_rw
tmp_pass=$4
tmp_host=db4-static.drupal.org
tmp_args="-h${tmp_host} -u${tmp_user} -p${tmp_pass} ${tmp_db}"

ln -sf /var/dumps $WORKSPACE/dumps

clear_tmp

mysqldump -h$db_host -u$db_user -p$db_pass --single-transaction $db_name 2> mysqldump-errors.txt | mysql -o ${tmp_args}
[ -s mysqldump-errors.txt ] && cat mysql-errors.txt && exit 1

echo "SHOW TABLES LIKE '%cache%';" | mysql -o ${tmp_args} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | mysql -o ${tmp_args}

suffix=.staging
snapshot
suffix=
snapshot
suffix=.reduce
snapshot

clear_tmp
