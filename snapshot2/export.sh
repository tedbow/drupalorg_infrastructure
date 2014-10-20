#!/bin/bash

set -uex
CWD=$(dirname "${BASH_SOURCE[0]}")
export DATE=$(date +'%Y%m%d%H%M')
export SANTYPE=$1
export SANOUT=$2
[ ! -f ${CWD}/conf ] && exit 1
source ${CWD}/conf
${CWD}/san-export.sh

