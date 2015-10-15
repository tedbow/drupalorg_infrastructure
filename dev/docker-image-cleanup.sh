#!/bin/bash

## Image clean up
# Get all devwww images
alldevwwwimages=$(docker images --no-trunc | grep devwww | awk '{print $3}' | sort -u)
# Get all latest devwww images
latestdevwwwimages=$(docker images --no-trunc | grep devwww | grep latest | awk '{print $3}' | sort -u)
# Get all devwww images that are being used by containers
devwwwcontainers=$(docker inspect --format '{{ .Image }}' $(docker ps -a | grep devwww | awk '{print $1}')  | sort -u)
# List of images to keep: latest images and images in use
keepdevwwwimages=$(sort -u <(echo "$devwwwcontainers") <(echo "$latestdevwwwimages"))
# List of images that can be removed
unuseddevwwwimages=$(comm -2 -3 <(echo "$alldevwwwimages") <(echo "$keepdevwwwimages"))
# list images that will be removed
echo "$unuseddevwwwimages"
# remove images
docker rmi $unuseddevwwwimages
