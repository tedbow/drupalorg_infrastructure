#!/bin/bash

## Image clean up
## Assumptions, an image:
##  is kept only if in use or latest
##  has one tag, unless it is the latest
##  is built on another system and loaded

# Get all dev images
alldevimages=$(docker images -q | sort -u)
# Get all latest dev images
latestdevimages=$(docker images | grep dev | grep latest | awk '{print $3}' | sort -u)
# Get all dev images that are being used by containers
containerimageid=$(docker ps -a | grep -v "CONTAINER ID" | awk '{print $2}' | sort -u)
# List of images to keep: latest images and images in use, do not print empty line
keepdevimages=$(sort -u <( [ ! -z "${containerimageid}" ] && echo "${containerimageid}") <( [ ! -z "${latestdevimages}" ] && echo "${latestdevimages}"))
# List of images that can be removed
unuseddevimages=$(comm -2 -3 <(echo "${alldevimages}") <(echo "${keepdevimages}"))
# Test if there are images to delete
# list images that will be removed
# Remove images if there are images to delete
[ ! -z "${unuseddevimages}" ] && echo "Images to delete ${unuseddevimages}" && docker rmi ${unuseddevimages} || echo "No image to remove"
