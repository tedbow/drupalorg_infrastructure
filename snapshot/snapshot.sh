#!/bin/bash

function snapshot {
  if [ -f "snapshot/common${suffix}.sql" ]; then
    echo "Running common SQL for ${suffix} snapshot"
    mysql -o ${tmp_args} < "snapshot/common${suffix}.sql" || exit 1
  fi

  [ ! -f "snapshot/${db_name}${suffix}.sql" ] && return
  echo "Running ${db_name} SQL for ${suffix} snapshot"
  mysql -o ${tmp_args} < "snapshot/${db_name}${suffix}.sql" || exit 1

  echo "Creating database dump"
  mysqldump --single-transaction ${tmp_args} | gzip > "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}-in-progress.sql.gz" || exit 1
  mv -v "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}-in-progress.sql.gz" "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}.sql.gz"
  ln -sfv "/var/dumps/mysql/${JOB_NAME}${suffix}-${BUILD_NUMBER}.sql.gz" "/var/dumps/mysql/${JOB_NAME}${suffix}-current.sql.gz"

  echo "Removing old database dump"
  rm -v $(ls -t /var/dumps/mysql/${JOB_NAME}${suffix}-[0-9]*.sql.gz | tail -n +2)
}

function clear_tmp {
  echo "Clearing out temporary database"
  echo "DROP DATABASE ${tmp_db}; CREATE DATABASE ${tmp_db};" | mysql ${tmp_args}
}

# Make sure we have required db info
if [ $# -lt 4 ]; then
  echo "Usage: $0 db_name db_user db_pass tmp_pass"
  echo "Where db_name is drupal, drupal_association, drupal_groups, drupal_security, etc."
  exit 1
fi

# Make sure these exist, otherwise bad things happen
if [ ! $JOB_NAME ]; then
  echo "\$JOB_NAME not defined, make sure to export these variables."
  exit 1
fi

# Configure credentials
db_name=$1
db_user=$2
db_pass=$3
db_host=db3-vip.drupal.org
[ "${db_name}" == "drupal" ] && db_host=db2-main-vip.drupal.org

tmp_db=drupal_sanitize
tmp_user=sanitize_rw
tmp_pass=$4
tmp_host=db4-static.drupal.org
tmp_args="-h${tmp_host} -u${tmp_user} -p${tmp_pass} ${tmp_db}"

ln -sf /var/dumps $WORKSPACE/dumps

clear_tmp

echo "Creating temporary database"
mysqldump -h$db_host -u$db_user -p$db_pass --single-transaction $db_name 2> mysqldump-errors.txt | mysql -o ${tmp_args}
[ -s mysqldump-errors.txt ] && exit 1

echo "Clearing cache tables"
echo "SHOW TABLES LIKE '%cache%';" | mysql -o ${tmp_args} | tail -n +2 | sed -e "s/^\(.*\)$/TRUNCATE \1;/" | mysql -o ${tmp_args}

suffix=.staging
snapshot
suffix=
snapshot
suffix=.reduce
snapshot

clear_tmp
