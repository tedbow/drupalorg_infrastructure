# EC2 configuration
. ~/.ec2creds
export EC2_HOME=/opt/ec2/ec2-api-tools-*
export EC2_URL=ec2.us-west-2.amazonaws.com
export JAVA_HOME=/usr

# Packer configuration
export PACKER_HOME=/opt/packer

# Repository configuration
base_repo=git@bitbucket.org:drupalorg-infrastructure/drupalci_base.git
api_repo=http://git.drupal.org/project/drupalci_api.git
dispatcher_repo=http://git.drupal.org/project/drupalci_jenkins.git
results_repo=http://git.drupal.org/project/drupalci_results.git

deregisterAMI() {
  for ami in $($EC2_HOME/bin/ec2-describe-images | awk "/$1/ "'{ print $2 }' | head -n-3); do
    $EC2_HOME/bin/ec2-deregister $ami
  done
}

latestBaseAMI() {
  $EC2_HOME/bin/ec2-describe-images | awk '/DrupalCI D.O base image/ { ami=$2 } END { print ami }'
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

fetchGit() {
  case "$1" in
    base)
      if [ -d drupalci_$1 ]; then
        cd drupalci_$1
        git pull
      else
        git clone $base_repo
        cd drupalci_$1
      fi
      ;;
    api)
      if [ -d drupalci_$1 ]; then
        cd drupalci_$1
        git pull
      else
        git clone $api_repo
        cd drupalci_$1
      fi
      ;;
    dispatcher*)
      if [ -d drupalci_jenkins ]; then
        cd drupalci_jenkins
        git pull
      else
        git clone $dispatcher_repo
        cd drupalci_jenkins
      fi
      ;;
    results)
      if [ -d drupalci_$1 ]; then
        cd drupalci_$1
        git pull
      else
        git clone $results_repo
        cd drupalci_$1
      fi
      ;;
    *)
      echo $"Usage: $0 {base|api|dispatcher-master|dispatcher-slave|results}"
      exit 1
  esac
}
