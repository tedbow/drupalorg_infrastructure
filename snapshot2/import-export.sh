#!/bin/bash

set -uex
CWD=$(dirname "${BASH_SOURCE[0]}")
${CWD}/raw-import.sh
${CWD}/skel-export.sh

