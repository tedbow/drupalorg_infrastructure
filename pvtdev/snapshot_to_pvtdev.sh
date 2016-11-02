#!/bin/bash

# Copy and install the snapshot to a specified target database

set -uex

db=${1}
target_db=${2}
stage=staging

# Working directory
cd /data/dumps/
mkdir ${target_db} || true

# Copy and extract the latest snapshot from dbutil
## We're now using the rrsync script to limit access for rsync+ssh, this means
## the ssh is chroot'ed to the proper stage depending on the key in
## authorized_keys
rsync -v --copy-links --progress -e 'ssh -i /home/bender/.ssh/id_rsa' bender@dbutil1.drupal.bak:/${db}.${stage}-binary-current.tar.gz ./
tar -I pigz -xvf ${db}.${stage}-binary-current.tar.gz -C ${target_db}

chown -R mysql:mysql ./${target_db}/${db}/*
chown bender:bender ./${target_db}/{*.sql,$db}

# Just in case the tables aren't in the correct compressed format in the
# schema, ensure they are created with compression. Note: the binary data and the
# row format must match for tablespace import.
# @TODO verify row_format=compressed everywhere
perl -p -i -e 's/^\) ENGINE=InnoDB.*$/\) ENGINE=InnoDB ROW_FORMAT=compressed DEFAULT CHARSET=utf8\;/' ${target_db}/${db}.${stage}-schema.sql
mysql ${target_db} < /data/dumps/${target_db}/${db}.${stage}-schema.sql 

# Association sites also get the CiviCRM database in private environments
if [ ${db} == 'drupal_association' ]; then
  rsync -v --copy-links --progress -e 'ssh -i /home/bender/.ssh/id_rsa' bender@dbutil1.drupal.bak:/association_civicrm.${stage}-binary-current.tar.gz ./
  tar -I pigz -xvf association_civicrm.${stage}-binary-current.tar.gz -C ${target_db}
  chown -R mysql:mysql ./${target_db}/association_civicrm/*
  chown bender:bender ./${target_db}/{*.sql,association_civicrm}
  perl -p -i -e 's/^\) ENGINE=InnoDB.*$/\) ENGINE=InnoDB ROW_FORMAT=compressed DEFAULT CHARSET=utf8\;/' ${target_db}/association_civicrm.${stage}-schema.sql
  mysql ${target_db} < /data/dumps/${target_db}/association_civicrm.${stage}-schema.sql 
fi

# Discard the data files for the newly created tables
( mysql ${target_db} -e "SHOW TABLES" --batch --skip-column-names | xargs -t -n 1 -P 20 -I{} mysql -e 'SET FOREIGN_KEY_CHECKS=0; ALTER TABLE `'{}'` DISCARD TABLESPACE;' ${target_db})

# Copy the snapshot data files in place
mv ${target_db}/${db}/{*.ibd,*.cfg} /var/lib/mysql/${target_db}/

# Special copy for civicrm
if [ ${db} == 'drupal_association' ]; then
  mv ${target_db}/association_civicrm/{*.ibd,*.cfg} /var/lib/mysql/${target_db}/
fi

# Import the data from the copied data files
( mysql ${target_db} -e "SHOW TABLES" --batch --skip-column-names | xargs -t -n 1 -P 3 -I{} mysql -e 'SET FOREIGN_KEY_CHECKS=0; ALTER TABLE `'{}'` IMPORT TABLESPACE;' ${target_db})

# Analyze tables to let mysql understand indexes
( mysql ${target_db} -e "SHOW TABLES" --batch --skip-column-names | xargs -t -n 1 -P 20 -I{} mysql -e 'ANALYZE TABLE `'{}'`;' ${target_db})

# Cleanup the temporary $target_db directory
rm -rf /data/dumps/${target_db}
