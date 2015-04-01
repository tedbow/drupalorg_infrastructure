# EC2 configuration
. ~/.ec2creds
export EC2_HOME=/opt/ec2/ec2-api-tools-1.7.3.2
export EC2_URL=ec2.ap-southeast-2.amazonaws.com
export JAVA_HOME=/usr

# Packer configuration
export PACKER_HOME=/opt/packer

# Repository configuration
base_repo=git@bitbucket.org:drupalorg-infrastructure/drupalci_base.git
api_repo=https://github.com/drupalci/api.git
dispatcher_repo=https://github.com/drupalci/dispatcher.git
results_repo=https://github.com/drupalci/results.git


latestBaseAMI() {
  $EC2_HOME/bin/ec2-describe-images | awk '/DrupalCI D.O base image/ { ami=$2 } END { print ami }'
}

buildBaseAMI() {
  $PACKER_HOME/packer build $1
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
      if [ -d $1 ]; then
        cd $1
        git pull
      else
        git clone $api_repo
        cd $1
      fi
      ;;
    dispatcher)
      if [ -d $1 ]; then
        cd $1
        git pull
      else
        git clone $dispatcher_repo
        cd $1
      fi
      ;;
    results)
      if [ -d $1 ]; then
        cd $1
        git pull
      else
        git clone $results_repo
        cd $1
      fi
      ;;
    *)
      echo $"Usage: $0 {base|api|dispatcher|results}"
      exit 1
  esac
}
