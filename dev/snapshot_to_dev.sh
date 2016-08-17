#!/bin/bash

# Copy and install the snapshot to a specified target database

set -uex

db=${1}
target_db=${2}
stage=dev

# Working directory
cd /data/dumps/
mkdir ${target_db}

# Copy and extract the latest snapshot from dbutil
rsync -v --copy-links --progress -e 'ssh -i /home/bender/.ssh/id_rsa' bender@dbutil1.drupal.bak:/var/dumps/${stage}/${db}.${stage}-binary-current.tar.gz ./
tar -I pigz -xvf ${db}.${stage}-binary-current.tar.gz -C ${target_db}

# @TODO fix the extract path upstream, so the drupal db extracts to the correct
# drupal directory (instead of drupal_export)
if [ ${db} == 'drupal' ]; then
  chown -R mysql:mysql ./${target_db}/drupal_export/*
  chown bender:bender ./${target_db}/{*.sql,drupal_export}
else
  chown -R mysql:mysql ./${target_db}/${db}/*
  chown bender:bender ./${target_db}/{*.sql,$db}
fi

# Just in case the tables aren't in the correct compressed format in the
# schema, ensure they are created with compression. Note: the binary data and the
# row format must match for tablespace import.
# @TODO verify row_format=compressed everywhere
perl -p -i -e 's/^\) ENGINE=InnoDB.*$/\) ENGINE=InnoDB ROW_FORMAT=compressed DEFAULT CHARSET=utf8\;/' ${target_db}/${db}.${stage}-schema.sql
mysql ${target_db} < /data/dumps/${target_db}/${db}.${stage}-schema.sql 

# Discard the data files for the newly created tables
( mysql ${target_db} -e "SHOW TABLES" --batch --skip-column-names | xargs -n 1 -P 6 -I{} mysql -e 'ALTER TABLE `'{}'` DISCARD TABLESPACE;' ${target_db})

# Copy the snapshot data files in place
if [ ${db} == 'drupal' ]; then
  mv ${target_db}/drupal_export/{*.ibd,*.cfg} /var/lib/mysql/${target_db}/
else
  mv ${target_db}/${db}/{*.ibd,*.cfg} /var/lib/mysql/${target_db}/
fi

# Import the data from the copied data files
( mysql ${target_db} -e "SHOW TABLES" --batch --skip-column-names | xargs -n 1 -P 6 -I{} mysql -e 'ALTER TABLE `'{}'` IMPORT TABLESPACE;' ${target_db})

# Analyze tables to let mysql understand indexes
( mysql ${target_db} -e "SHOW TABLES" --batch --skip-column-names | xargs -n 1 -P 6 -I{} mysql -e 'ANALYZE TABLE `'{}'`;' ${target_db})

# Cleanup the temporary $target_db directory
rm -rf /data/dumps/${target_db}

