#/bin/bash

source /usr/local/drupal-infrastructure/drupalci/common.sh

case "$1" in
  base)
    gitFetch $1
    buildBaseAMI
    ;;
  api)
    gitFetch $1
    buildAMI
    ;;
  dispatcher)
    gitFetch $1
    buildAMI
    ;;
  results)
    gitFetch $1
    buildAMI
    ;;
  *)
    echo $"Usage: $0 {base|api|dispatcher|results}"
    exit 1
esac

