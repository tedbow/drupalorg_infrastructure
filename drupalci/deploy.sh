#/bin/bash
source /usr/local/drupal-infrastructure/drupalci/common.sh

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

case "$1" in
  api)
    ./aws_deploy --elb=apibal --ami=$(latestAMI 'DrupalCI API') --key=id_rsa-drupalci --region=us-west-2 --tags="Name=API,Environment=Production" --security='sg-a2bfbbc7'
    ;;
  dispatcher-master)
    ./aws_deploy --elb=dispatcherbal --ami=$(latestAMI 'DrupalCI master') --key=id_rsa-drupalci --region=us-west-2 --tags="Name=Dispatcher,Environment=Production" --security='sg-53f74236'
    ;;
  results)
    ./aws_deploy --elb=resultsbal --ami=$(latestAMI 'DrupalCI Results') --key=id_rsa-drupalci --region=us-west-2 --tags="Name=Results,Environment=Production" --security='sg-5db9bd38'
    ;;
  *)
    echo $"Usage: $0 {api|dispatcher-master|results}"
    exit 1
esac
