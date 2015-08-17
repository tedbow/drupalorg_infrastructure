#!/bin/bash
set -eux

weektimestamp=$1

#clear out existing data - script reruns do not accumluate data
rm -rf /data/stats/updatestats/counts/$weektimestamp.*

# Handle project/release usage counts

# Sort and uniq the project/release usage data per week (eliminates extra calls from the same site key.)
{ time multisort -f -S 75% -T /data/stats/updatestats/tmpdir -u /data/stats/updatestats/reformatted/$weektimestamp/projects/*.formatted > /data/stats/updatestats/counts/$weektimestamp.project_counts.uniq.sorted ; } 2>&1

# Find the number of unique sites asking us for data that week
{ time cut -f1 -d"|" /data/stats/updatestats/counts/$weektimestamp.project_counts.uniq.sorted |uniq -i |wc -l > /data/stats/updatestats/counts/$weektimestamp.uniquesitekeys ; } 2>&1
# Count the release uses
{ time cut -f2,3,4 -d"|" /data/stats/updatestats/counts/$weektimestamp.project_counts.uniq.sorted |multisort -f -S 75% -T /data/stats/updatestats/tmpdir |uniq -c -i |sort -n > /data/stats/updatestats/counts/$weektimestamp.releasecounts ; } 2>&1
# Count the project uses
{ time cut -f2,4 -d"|" /data/stats/updatestats/counts/$weektimestamp.project_counts.uniq.sorted |multisort -f -S 75% -T /data/stats/updatestats/tmpdir |uniq -c -i |sort -n > /data/stats/updatestats/counts/$weektimestamp.projectapicounts ; } 2>&1

# Handle submodules usage counts

# Sort and uniq the submodule usage data per week (eliminates extra calls from the same site key.)
{ time multisort -f -S 75% -T /data/stats/updatestats/tmpdir -u /data/stats/updatestats/reformatted/$weektimestamp/submodules/*.formatted > /data/stats/updatestats/counts/$weektimestamp.submodule_counts.uniq.sorted ; } 2>&1
# Aggregate and count the project/release/submodule name
{ time cut -f2,3,4,5 -d"|" /data/stats/updatestats/counts/$weektimestamp.submodule_counts.uniq.sorted |multisort -f -S 75% -T /data/stats/updatestats/tmpdir |uniq -c -i |sort -n > /data/stats/updatestats/counts/$weektimestamp.submodule_release_counts; } 2>&1
# Aggregate and count the project/submodule name
{ time cut -f2,4,5 -d"|" /data/stats/updatestats/counts/$weektimestamp.submodule_counts.uniq.sorted |multisort -f -S 75% -T /data/stats/updatestats/tmpdir |uniq -c -i |sort -n > /data/stats/updatestats/counts/$weektimestamp.submodule_project_counts; } 2>&1

# Handle keyless project use counts

# Sort and uniq the keyless project usage data per week (eliminates extra calls from the same ip address.)
{ time multisort -f -S 75% -T /data/stats/updatestats/tmpdir -u /data/stats/updatestats/reformatted/$weektimestamp/keyless/*.formatted > /data/stats/updatestats/counts/$weektimestamp.keyless_counts.uniq.sorted ; } 2>&1
{ time cut -f2,3 -d"|" /data/stats/updatestats/counts/$weektimestamp.keyless_counts.uniq.sorted |multisort -f -S 75% -T /data/stats/updatestats/tmpdir |uniq -c -i |sort -n > /data/stats/updatestats/counts/$weektimestamp.keyless_project_counts; } 2>&1
