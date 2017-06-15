#!/bin/bash
 set -uex

 # This script is intended to be ran in order to re-create the replica database using xtrabackup from the master database.

 #Gather some variables
 PRIMARY=$(crm status --as-xml |xpath -q -e "string(/crm_mon/resources/clone/resource[@role='Master']/node/@name)" 2>/dev/null)

 # NOTE: REPLICA may need to be set manually if its not showing up as a 'Slave' resource
 REPLICA=$(crm status --as-xml |xpath -q -e "string(/crm_mon/resources/clone/resource[@role='Slave']/node/@name)" 2>/dev/null)
 #REPLICA=db5

 PRIMARY_IP=$(crm status --as-xml |xpath -q -e "string(/crm_mon/node_attributes/node[@name='${PRIMARY}']/attribute[@name='p_mysql_mysql_master_IP']/@value)" 2>/dev/null)
 REPLICATION_PW=$(crm configure show xml |xpath -q -e "string(/cib/configuration/resources/master/primitive/instance_attributes/nvpair[@id='p_mysql-instance_attributes-replication_passwd']/@value)" 2>/dev/null)


 #disable puppet on both nodes
 # Maybe check with cat `puppet agent --configprint agent_disabled_lockfile` ?
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync "/opt/puppetlabs/bin/puppet agent --disable"
 ssh root@${PRIMARY}.drupal.bak -i ~/.ssh/dbresync "/opt/puppetlabs/bin/puppet agent --disable"
 # Disable oak purge logs crontab while we work
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '(crontab -l | sed "/^[^#].*oak-purge-master-logs/s/^/#/" |crontab -)'
 ssh root@${PRIMARY}.drupal.bak -i ~/.ssh/dbresync '(crontab -l | sed "/^[^#].*oak-purge-master-logs/s/^/#/" |crontab -)'

 # Take the Replica out of the cluster
 crm node standby ${REPLICA}

 # Blow away mysql on our out of sync replica.
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '(rm -rf /var/lib/mysql/* /data/mysql/*)'

 # Stream a backup to the replica from the primary
 ssh root@${PRIMARY}.drupal.bak -i ~/.ssh/dbresync "(innobackupex --safe-slave-backup --use-memory=4G --compress --parallel=16 --stream=xbstream /var/drupal_sanitize/ | ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync \"/usr/bin/xbstream -x -C /var/lib/mysql/\" )"

 # Decompress the backup
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '( innobackupex --decompress --parallel=16 /var/lib/mysql )'

 # Update the logs, bringing mysql back up to date
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '( innobackupex --apply-log --use-memory=48G /var/lib/mysql/ )'

 # move the logfiles back to /data/mysql
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '( mv /var/lib/mysql/ib_logfile* /data/mysql/ )'
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '( mv /var/lib/mysql/ibdata1 /data/mysql/ )'

 # Make sure everything is owned by mysql
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '( chown -R mysql:mysql /data/mysql /var/lib/mysql  )'

 #Restart mysql. twice. just in case.
 # There must be, 50 ways to start mysql
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '( /etc/init.d/mysql stop )'
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '( /etc/init.d/mysql start )'
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '( /etc/init.d/mysql start )'

 BINLOG_FILE=$(ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync "( awk '{split(\$1,binlog,\"/\"); print binlog[4]}' /var/lib/mysql/xtrabackup_binlog_pos_innodb )")
 BINLOG_POS=$(ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync "( awk '{print \$2}' /var/lib/mysql/xtrabackup_binlog_pos_innodb )")

 sleep 20;
 # Put the replica back on the rails and catch it back up.
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync "( /usr/bin/mysql --database=mysql -e \"STOP SLAVE; CHANGE MASTER TO master_host='${PRIMARY_IP}', master_user='repl_user', master_password='${REPLICATION_PW}', master_log_file='${BINLOG_FILE}', master_log_pos=${BINLOG_POS};START SLAVE;\"  )"

 # Turn off regular mysql and put it back on into the cluster
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '( mysqladmin shutdown )'
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '( crm node clearstate ${REPLICA} )'
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '( crm node online ${REPLICA} )'

 # Re-enable puppet
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync "/opt/puppetlabs/bin/puppet agent --enable"
 ssh root@${PRIMARY}.drupal.bak -i ~/.ssh/dbresync "/opt/puppetlabs/bin/puppet agent --enable"
 # Re-enable oak purge logs crontab while we work
 ssh root@${REPLICA}.drupal.bak -i ~/.ssh/dbresync '(crontab -l | sed "/^#.*oak-purge-master-logs/s/^#//" |crontab -)'
 ssh root@${PRIMARY}.drupal.bak -i ~/.ssh/dbresync '(crontab -l | sed "/^#.*oak-purge-master-logs/s/^#//" |crontab -)'
