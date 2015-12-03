# EC2 configuration
. ~/.ec2credsbdd
export EC2_HOME=/opt/ec2/ec2-api-tools-1.7.3.2
export EC2_URL=ec2.us-west-2.amazonaws.com
export JAVA_HOME=/usr

# Packer configuration
export PACKER_HOME=/opt/packer

deregisterAMI() {
  for ami in $($EC2_HOME/bin/ec2-describe-images | awk "/$1/ "'{ print $2 }' | head -n-3); do
    $EC2_HOME/bin/ec2-deregister $ami
  done
}

latestBaseAMI() {
  $EC2_HOME/bin/ec2-describe-images | awk '/DrupalOrg BDD base image/ { ami=$2 } END { print ami }'
}

buildBaseAMI() {
  $PACKER_HOME/packer build $1
}

latestAMI() {
  $EC2_HOME/bin/ec2-describe-images | awk "/$1/ "'{ ami=$2 } END { print ami }'
}

buildAMI() {
  $PACKER_HOME/packer build -var "source_ami=$(latestBaseAMI)" $1
}
