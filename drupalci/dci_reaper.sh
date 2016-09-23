#!/bin/bash
# Terminate or notify of instances which may be wasting DA monies

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

hoursago=$(date --date '11 hours ago' +%Y-%m-%d\T%H\:%m\:%S)

# Query for instances running for > 11 hours that were never tagged with the
# Testrunner name
instances=$(aws ec2 describe-instances --filters \
  "Name=instance-type,Values=cc2.8xlarge" \
  "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{InstanceId: InstanceId, LaunchTime: LaunchTime, Name: Tags[?Key==`Name`].Value}' \
  | jq ".[] | select(.LaunchTime < \"$hoursago\") | select(.Name == null)" | jq --raw-output ".InstanceId")

# Verify $instances contains real data and not just IFS
if [ "x`printf '%s' "$instances" | tr -d "$IFS"`" != x ]; then
  echo "Unprovisioned instances detected"
  # Terminate instances
  #aws ec2 terminate-instances --instance-ids ${instances}
  #aws ec2 describe-instances --instance-ids ${instances} \
  #  --query 'Reservations[].Instances[].{InstanceId: InstanceId, LaunchTime: LaunchTime, Name: Tags[?Key==`Name`].Value}' | \
  #  jq '.' | mail -s "[drupalci_reaper] Instances: ${instances} are untagged" sitemaint@association.drupal.org
fi

# Query for instances running for > $hoursago
instances=$(aws ec2 describe-instances --filters \
  "Name=instance-type,Values=cc2.8xlarge" \
  "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{InstanceId: InstanceId, LaunchTime: LaunchTime, Name: Tags[?Key==`Name`].Value}' \
  | jq ".[] | select(.LaunchTime < \"$hoursago\")" | jq --raw-output ".InstanceId")

# Verify $instances contains real data and not just IFS
if [ "x`printf '%s' "$instances" | tr -d "$IFS"`" != x ]; then
  echo "Long running instances (> 11 hours) detected"
  aws ec2 describe-instances --instance-ids ${instances} \
    --query 'Reservations[].Instances[].{InstanceId: InstanceId, LaunchTime: LaunchTime, Name: Tags[?Key==`Name`].Value}' | \
    jq '.' | mail -s "[drupalci_reaper] Instances: ${instances} have been running for > 11 hours" sitemaint@association.drupal.org
  aws ec2 terminate-instances --instance-ids ${instances}
fi
