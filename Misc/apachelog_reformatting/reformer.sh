#!/bin/bash
echo $1
zcat $1 |/usr/bin/httpdreformatter.awk --assign file=${1%.log.gz}

#This ran on loghost to reformat the old apache log files into the same format as the current apache log files.
