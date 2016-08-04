#!/bin/bash -e

############################################
# Use this script to load all containers
############################################
echo "** START: $(date) **"
for image in $(ls); do
  pbunzip2 -dc < ${image} | docker load
done
echo "** END: $(date) **"

