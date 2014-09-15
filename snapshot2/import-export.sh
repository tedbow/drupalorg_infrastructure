#!/bin/bash

set -uex
CWD=$(dirname "${BASH_SOURCE[0]}")
[ ! -f ${CWD}/conf ] && exit 1
source ${CWD}/conf
${CWD}/raw-import.sh
${CWD}/skel-export.sh

