#!/bin/bash

#set -eux
echo $1
pigz -d $1
/usr/local/drupal-infrastructure/stats/edgecastusagestatparser.awk ${1%.gz}
pigz ${1%.gz}
