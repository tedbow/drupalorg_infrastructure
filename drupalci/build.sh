#/bin/bash
source /usr/local/drupal-infrastructure/drupalci/common.sh

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

fetchGit $1

case "$1" in
  base)
    buildBaseAMI packer.json
    ;;
  api)
    buildAMI packer/packer.json
    ;;
  dispatcher-master)
    buildAMI packer/master/packer.json
    ;;
  dispatcher-slave)
    buildAMI packer/slave/packer.json
    ;;
  results)
    buildAMI packer/packer.json
    ;;
  *)
    echo $"Usage: $0 {base|api|dispatcher-master|dispatcher-slave|results}"
    exit 1
esac
