#/bin/bash
source /usr/local/drupal-infrastructure/drupalci/aws_dispatcher_snapshot/aws_common.sh

DATE=$(date +'%Y%m%d%H%M')
DESCRIPTOR="auto_dispatcher_/dev"

# freebsd-dispatcher-root
create_ebs_snapshot 'vol-b8a67cad' "${DATE}_${DESCRIPTOR}/sda1"

# freebsd-dispatcher-jenkins-pool
create_ebs_snapshot 'vol-a160bbb4' "${DATE}_${DESCRIPTOR}/sdf"
