#!/bin/bash

# Grab the profile argument:
#
# Infra - infrastructure dev
# Boss - for drupal.org
# Skeleton - for drupal.org dev
profile=${1}

# We are only creating dev snapshots right now.
suffix=".dev"
subdir=$(echo "${suffix}" | sed -e 's/^\.//')

# Grab the host, user and password from password.py
host=$(cat sanitize/password.py | grep host | sed -e "s/host = '//" -e "s/'//")
user=$(cat sanitize/password.py | grep user | sed -e "s/user = '//" -e "s/'//")
password=$(cat sanitize/password.py | grep password | sed -e "s/password = '//" -e "s/'//")
tmp_args="-h${host} -u${user} -p${password}"

# Sanitize into the export database.
python26 ./sanitize/sanitize_db.py -s infrastructure -d drupal_export -p ${profile}

# Save the DB dump.
mysqldump --single-transaction --quick ${tmp_args} | sed -e 's/^) ENGINE=[^ ]*/)/' | bzip2 > "/var/dumps/${subdir}/${JOB_NAME}${suffix}-${BUILD_NUMBER}-in-progress.sql.bz2"
mv -v "/var/dumps/${subdir}/${JOB_NAME}${suffix}-${BUILD_NUMBER}-in-progress.sql.bz2" "/var/dumps/${subdir}/${JOB_NAME}${suffix}-${BUILD_NUMBER}.sql.bz2"
ln -sfv "${JOB_NAME}${suffix}-${BUILD_NUMBER}.sql.bz2" "/var/dumps/${subdir}/${JOB_NAME}${suffix}-current.sql.bz2"

# Remove old snapshots.
old_snapshots=$(ls -t /var/dumps/${subdir}/${JOB_NAME}${suffix}-[0-9]*.sql.{bz2,gz} | tail -n +2)
if [ -n "${old_snapshots}" ]; then
  rm -v ${old_snapshots}
fi
