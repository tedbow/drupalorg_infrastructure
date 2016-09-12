#!/bin/bash
# Terminate or notify of instances which may be wasting DA monies

minuteago=$(date --date '30 minutes ago' +%Y-%m-%d\T%H\:%m\:%S)
dayago=$(date --date '1 day ago' +%Y-%m-%d\T%H\:%m\:%S)

# Query for instances running for > 30 minutes that were never tagged with the
# Testrunner name
instances=$(aws ec2 describe-instances --filters \
  "Name=instance-type,Values=cc2.8xlarge" \
  "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{InstanceId: InstanceId, LaunchTime: LaunchTime, Name: Tags[?Key==`Name`].Value}' \
  | jq ".[] | select(.LaunchTime < \"$minuteago\") | select(.Name == null)" | jq --raw-output ".InstanceId")

# Verify $instances contains real data and not just IFS
if [ "x`printf '%s' "$instances" | tr -d "$IFS"`" != x ]; then
  echo "Unprovisioned instances detected"
  # Terminate instances
  #aws ec2 terminate-instances --instance-ids ${instances}
fi

# Query for instances running for > 24 hours
instances=$(aws ec2 describe-instances --filters \
  "Name=instance-type,Values=cc2.8xlarge" \
  "Name=instance-state-name,Values=running" \
  --query 'Reservations[].Instances[].{InstanceId: InstanceId, LaunchTime: LaunchTime, Name: Tags[?Key==`Name`].Value}' \
  | jq ".[] | select(.LaunchTime < \"$dayago\")" | jq --raw-output ".InstanceId")

# Verify $instances contains real data and not just IFS
if [ "x`printf '%s' "$instances" | tr -d "$IFS"`" != x ]; then
  echo "Long running (>24 hours) instances detected"
  aws ec2 describe-instances --instance-ids ${instances} | \
    mail -s "Instances: ${instances} have been running for > 24 hours" rudy@association.drupal.org
fi

