#/bin/bash
source /usr/local/drupal-infrastructure/drupalci/common.sh

# Exit immediately on uninitialized variable or error, and print each command.
set -uex


case "$1" in
  base)
    buildAMI packer/base/packer.json
    ;;
  bdd-dispatcher)
    buildAMI packer/dispatcher/packer.json
    ;;
  bdd-slave)
    buildAMI packer/slave/packer.json
    ;;
  *)
    echo $"Usage: $0 {base|bdd-dispatcher|bdd-slave}"
    exit 1
esac
