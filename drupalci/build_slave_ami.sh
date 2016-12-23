#!/bin/bash
# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# EC2 configuration
. ~/.ec2creds
export EC2_HOME=/opt/ec2/ec2-api-tools-1.7.3.2
export EC2_URL=ec2.us-west-2.amazonaws.com
export JAVA_HOME=/usr

# Packer configuration
export PACKER_HOME=/usr/local/bin

${PACKER_HOME}/packer build packer/packer.json
