#/bin/bash
source /usr/local/drupal-infrastructure/drupalci/aws_dispatcher_snapshot/aws_common.sh

date31=$(date --date="31 days ago" +'%Y%m%d%H%M')

descriptor="auto_dispatcher_/dev"

delete_old_ebs_snapshots "${date31}" "${descriptor}"
