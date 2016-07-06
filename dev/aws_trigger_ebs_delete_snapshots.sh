#/bin/bash
source /usr/local/drupal-infrastructure/dev/aws_common.sh

date2=$(date --date="2 days ago" +'%Y%m%d%H%M')

descriptor="auto_devwww2_/dev"

delete_old_ebs_snapshots "${date2}" "${descriptor}"
