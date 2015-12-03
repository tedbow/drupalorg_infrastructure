#/bin/bash
source /usr/local/drupal-infrastructure/bdd/packer/common.sh

# Exit immediately on uninitialized variable or error, and print each command.
set -uex


case "$1" in
  base)
    buildBaseMI base/packer.json
    ;;
  bdd-dispatcher)
    buildAMI dispatcher/packer.json
    ;;
  bdd-slave)
    buildAMI slave/packer.json
    ;;
  *)
    echo $"Usage: $0 {base|bdd-dispatcher|bdd-slave}"
    exit 1
esac
