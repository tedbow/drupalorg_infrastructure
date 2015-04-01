#/bin/bash

. ~/.ec2creds
export EC2_HOME=/opt/ec2/ec2-api-tools-1.7.3.2
export EC2_URL=ec2.ap-southeast-2.amazonaws.com
export JAVA_HOME=/usr
export PACKER_HOME=/opt/packer

latestBaseAMI() {
  $EC2_HOME/bin/ec2-describe-images | awk '/DrupalCI D.O base image/ { ami=$2 } END { print ami }'
}

buildBaseAMI() {
  $PACKER_HOME/packer build packer/packer.json
}

buildAMI() {
  $PACKER_HOME/packer build -var "source_ami=$(latestBaseAMI)" packer/packer.json
}
