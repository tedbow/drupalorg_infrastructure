#/bin/bash
source /usr/local/drupal-infrastructure/dev/aws_common.sh

date4=$(date --date="4 days ago" +'%Y%m%d%H%M')

descriptor="auto_devwww2_/dev"

delete_old_ebs_snapshots "${date4}" "${descriptor}"
