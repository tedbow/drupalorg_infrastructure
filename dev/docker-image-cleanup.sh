#!/bin/bash

## Image clean up
# Get all dev images
alldevimages=$(docker images --no-trunc | grep dev | awk '{print $3}' | sort -u)
# Get all latest dev images
latestdevimages=$(docker images --no-trunc | grep dev | grep latest | awk '{print $3}' | sort -u)
# Get all dev images that are being used by containers
devcontainers=$(docker inspect --format '{{ .Image }}' $(docker ps -a | grep dev | awk '{print $1}')  | sort -u)
# List of images to keep: latest images and images in use
keepdevimages=$(sort -u <(echo "$devcontainers") <(echo "$latestdevimages"))
# List of images that can be removed
unuseddevimages=$(comm -2 -3 <(echo "$alldevimages") <(echo "$keepdevimages"))
# list images that will be removed
echo "$unuseddevimages"
# remove images
docker rmi $unuseddevimages
