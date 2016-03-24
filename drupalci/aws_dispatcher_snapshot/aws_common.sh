#!/bin/bash
# EC2 configuration
. ~/.ec2creds_dispatcher-bender_snapshot
export EC2_HOME=/opt/ec2/ec2-api-tools-1.7.3.2
export EC2_URL=ec2.us-west-2.amazonaws.com
export JAVA_HOME=/usr

create_ebs_snapshot() {
  $EC2_HOME/bin/ec2-create-snapshot -d "${2}" "${1}"
}

delete_ebs_snapshot() {
  $EC2_HOME/bin/ec2-delete-snapshot "${1}"
}

describe_snapshots () {
  $EC2_HOME/bin/ec2-describe-snapshots
}

# Keep 4 snapshots
delete_old_ebs_snapshots() {
  date31="${1}"
  descriptor="${2}"
  # example
  # SNAPSHOT	snap-13f74f51	vol-242efbc2	completed	2016-03-21T18:34:30+0000	100%	353626856714	400	201603211833_devwww2_/dev/sdj	Not Encrypted
  # Get snapshots that contain the descriptor and are completed
  describe_snapshots | grep 'SNAPSHOT' | grep "${descriptor}" | grep completed | while read i ; do
    # check if the date is of the snapshot is older/smaller than $date31 and delete if it is.
    [[ $(echo ${i} | awk '{print $9}' | awk -F_ '{print $1}') -lt ${date31} ]] && delete_ebs_snapshot $(echo ${i} | awk '{print $2}'); done
}
