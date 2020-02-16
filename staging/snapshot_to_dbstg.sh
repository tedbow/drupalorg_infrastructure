#!/bin/bash

# Copy and install the snapshot to a specified target database

set -uex

db=${1}
target_db=${2}
stage=staging

# Fix db name's for non-conformists
case ${db} in
  'drupal_staging')
    db='drupal'
    ;;
  'drupal_events')
    db='events'
    ;;
  *)
    ;;
esac

# Remove stale data, if it exists
if ! mysql -e "DROP DATABASE IF EXISTS ${target_db};"; then
  # Probably can’t be dropped because the directory is not empty.
  rm -rfv /var/lib/mysql/${target_db}/{*.ibd,*.cfg,*.frm}
  mysql -e "DROP DATABASE IF EXISTS ${target_db};"
fi
mysql -e "CREATE DATABASE ${target_db};"

# Copy and import the latest snapshot’s schema from dbutil.
rsync -v --copy-links --whole-file --progress -e 'ssh -i /home/bender/.ssh/id_rsa' "bender@dbutil1.drupal.bak:/${db}.${stage}-schema-current.sql" '/data/dumps'
mysql ${target_db} < "/data/dumps/${db}.${stage}-schema-current.sql"

# Ensure tables have compression. The binary data and the row format must match
# for tablespace import.
( mysql "${target_db}" -e "SHOW TABLES" --batch --skip-column-names | grep -v --line-regexp 'civicrm_domain_view' | xargs -t -n 1 -P 20 -I{} mysql -e 'ALTER TABLE `'{}'` ROW_FORMAT=COMPRESSED;' "${target_db}")

# Discard the data files for the newly created tables
( mysql ${target_db} -e "SHOW TABLES" --batch --skip-column-names | grep -v --line-regexp 'civicrm_domain_view' | xargs -t -n 1 -P 20 -I{} mysql -e 'SET FOREIGN_KEY_CHECKS=0; ALTER TABLE `'{}'` DISCARD TABLESPACE;' ${target_db})

# Copy and extract the latest snapshot from dbutil
## We're now using the rrsync script to limit access for rsync+ssh, this means
## the ssh is chroot'ed to the proper stage depending on the key in
## authorized_keys
rsync -v --copy-links --whole-file --progress -e 'ssh -i /home/bender/.ssh/id_rsa' "bender@dbutil1.drupal.bak:/${db}.${stage}-binary-current.tar.gz" '/data/dumps'
tar -I pigz --strip-components=2 -xvf "/data/dumps/${db}.${stage}-binary-current.tar.gz" -C "/var/lib/mysql/${target_db}/"
rm "/data/dumps/${db}.${stage}-binary-current.tar.gz"
chown -Rv mysql:mysql "/var/lib/mysql/${target_db}/"

# Import the data from the copied data files
( mysql ${target_db} -e "SHOW TABLES" --batch --skip-column-names | grep -v --line-regexp 'civicrm_domain_view' | xargs -t -n 1 -P 3 -I{} mysql -e 'SET FOREIGN_KEY_CHECKS=0; ALTER TABLE `'{}'` IMPORT TABLESPACE;' ${target_db})

# Analyze tables to let mysql understand indexes
( mysql ${target_db} -e "SHOW TABLES" --batch --skip-column-names | grep -v --line-regexp 'civicrm_domain_view' | xargs -t -n 1 -P 20 -I{} mysql -e 'ANALYZE TABLE `'{}'`;' ${target_db})
