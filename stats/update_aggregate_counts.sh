#!/bin/bash
set -eux

weektimestamp=$1

#clear out existing data - script reruns do not accumluate data
rm -rf /data/logs/updatestats/project_counts/$weektimestamp
mkdir -p /data/logs/updatestats/project_counts/$weektimestamp
rm -rf /data/logs/updatestats/submodule_counts/$weektimestamp
mkdir -p /data/logs/updatestats/submodule_counts/$weektimestamp
rm -rf /data/logs/updatestats/keyless_counts/$weektimestamp
mkdir -p /data/logs/updatestats/keyless_counts/$weektimestamp
#

# Handle project/release usage counts

# Sort and uniq the project/release usage data per week (eliminates extra calls from the same site key.)
{ time multisort -f -S 75% -T /data/logs/updatestats/tmpdir -u /data/logs/updatestats/reformatted/$weektimestamp/*.formatted > /data/logs/updatestats/project_counts/$weektimestamp/$weektimestamp.uniq.sorted ; } 2>&1

# Find the number of unique sites asking us for data that week
{ time cut -f1 -d"|" /data/logs/updatestats/project_counts/$weektimestamp/$weektimestamp.uniq.sorted |uniq -i |wc -l > /data/logs/updatestats/project_counts/$weektimestamp/$weektimestamp.uniquesitekeys ; } 2>&1
# Count the release uses
{ time cut -f2,3,4 -d"|" /data/logs/updatestats/project_counts/$weektimestamp/$weektimestamp.uniq.sorted |multisort -f -S 75% -T /data/logs/updatestats/tmpdir |uniq -c -i |sort -n > /data/logs/updatestats/project_counts/$weektimestamp/$weektimestamp.releasecounts ; } 2>&1
# Count the project uses
{ time cut -f2,4 -d"|" /data/logs/updatestats/project_counts/$weektimestamp/$weektimestamp.uniq.sorted |multisort -f -S 75% -T /data/logs/updatestats/tmpdir |uniq -c -i |sort -n > /data/logs/updatestats/project_counts/$weektimestamp/$weektimestamp.projectapicounts ; } 2>&1

# Handle submodules usage counts

# Sort and uniq the submodule usage data per week (eliminates extra calls from the same site key.)
{ time multisort -f -S 75% -T /data/logs/updatestats/tmpdir -u /data/logs/updatestats/submodules/$weektimestamp/*.formatted > /data/logs/updatestats/submodule_counts/$weektimestamp/$weektimestamp.uniq.sorted ; } 2>&1
# Aggregate and count the project/release/submodule name
{ time cut -f2,3,4,5 -d"|" /data/logs/updatestats/submodule_counts/$weektimestamp/$weektimestamp.uniq.sorted |multisort -f -S 75% -T /data/logs/updatestats/tmpdir |uniq -c -i |sort -n > /data/logs/updatestats/submodule_counts/$weektimestamp/$weektimestamp.submodule_release_counts; } 2>&1
# Aggregate and count the project/submodule name
{ time cut -f2,4,5 -d"|" /data/logs/updatestats/submodule_counts/$weektimestamp/$weektimestamp.uniq.sorted |multisort -f -S 75% -T /data/logs/updatestats/tmpdir |uniq -c -i |sort -n > /data/logs/updatestats/submodule_counts/$weektimestamp/$weektimestamp.submodule_project_counts; } 2>&1

# Handle keyless project use counts

# Sort and uniq the keyless project usage data per week (eliminates extra calls from the same ip address.)
{ time multisort -f -S 75% -T /data/logs/updatestats/tmpdir -u /data/logs/updatestats/keyless/$weektimestamp/*.nokey > /data/logs/updatestats/keyless_counts/$weektimestamp/$weektimestamp.uniq.sorted ; } 2>&1
{ time cut -f2,3 -d"|" /data/logs/updatestats/keyless_counts/$weektimestamp/$weektimestamp.uniq.sorted |multisort -f -S 75% -T /data/logs/updatestats/tmpdir |uniq -c -i |sort -n > /data/logs/updatestats/keyless_counts/$weektimestamp/$weektimestamp.keyless_project_counts; } 2>&1
