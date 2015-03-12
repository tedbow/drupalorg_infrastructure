#!/bin/gawk -f
# Extracts the download counts from the awstats files and puts them into the same format as
# the daily fastly logs
# filenames are in the following pattern: awstats032015.ftp.drupal.org.txt
# Only process lines between the following patterns by setting a variable to true saying "we've hit this point in the file"

/END_SIDER/ {processflag=0};


# Reformat into our stats format - Count, Y, M, D, Filename - these files are monthly so they have no Day.
processflag {
  # Remove ftp.drupal.org if its there.
  gsub(/http:\/\/ftp.drupal.org/,"",$1)
  #Trim off leading slash
  filename=substr($1,2);
  print $2 "," substr(FILENAME,10,4) "," substr(FILENAME,8,2) "," "," filename >> ("/data/logs/downloadcounts/"substr(FILENAME,10,4)"."substr(FILENAME,8,2)".00.downloadcounts.csv")
};

# This goes after so we do not process the line this is on.
/BEGIN_SIDER .*/{processflag=1};
