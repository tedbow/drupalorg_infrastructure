#!/bin/gawk
# Reads in all of the download count files and aggregates the counts together.

# Set the Field Separator
BEGIN {FS=","}

# Aggregate the filename counts. $5 is the filename $1 is the count.
{downloaded_files[$5] += $1;}

END {
  for (filename in downloaded_files) print downloaded_files[filename] "," filename;
}
