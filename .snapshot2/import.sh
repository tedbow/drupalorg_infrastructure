#!/bin/bash

set -uex
CWD=$(dirname "${BASH_SOURCE[0]}")
export DATE=$(date +'%Y%m%d%H%M')
[ ! -f ${CWD}/conf ] && exit 1
source ${CWD}/conf
${CWD}/raw-import.sh

