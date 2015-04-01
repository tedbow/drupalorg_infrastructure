#/bin/bash
source /usr/local/drupal-infrastructure/drupalci/common.sh

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

fetchGit $1

case "$1" in
  base)
    buildBaseAMI
    ;;
  api)
    buildAMI
    ;;
  dispatcher)
    buildAMI
    ;;
  results)
    buildAMI
    ;;
  *)
    echo $"Usage: $0 {base|api|dispatcher|results}"
    exit 1
esac
