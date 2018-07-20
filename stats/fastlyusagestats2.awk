#!/usr/bin/mawk -f

 # Takes in fastly syslog entries and creates daily aggregate counts for download statistics
 # A sample line looks like the following:
 # 2015-06-27T00:00:00Z cache-ams4140 fastlyupdates[310]: 144.76.104.230 | "-" | "-" | 2015-06-26 | 23:59:59 +0000 | GET /release-history/metatag/7.x?site_key=IPfiGkPnKUfj6HIFgEQXFo0JyCXwfP5R9QQZxMCLJJA&version=7.x-1.5&list=metatag%2Cmetatag_context | 200 | (null) | Drupal (+http://drupal.org/)

BEGIN {
       OFS=",";
        #blow away any existing files for this filename, in case we reprocess.
        # FILENAME isnt available in BEGIN blocks. Because magic.
        system("rm -rf /data/stats/updatestats/sitemodel/" ARGV[1] ".host_table");
        system("rm -rf /data/stats/updatestats/sitemodel/" ARGV[1] ".site_table");
        system("rm -rf /data/stats/updatestats/sitemodel/" ARGV[1] ".host_site_table");
        system("rm -rf /data/stats/updatestats/sitemodel/" ARGV[1] ".project_version_table");
        system("rm -rf /data/stats/updatestats/sitemodel/" ARGV[1] ".submodule_table");
       }
 { # Only operate on lines with files/projects in them - ignore translations
if (NR % 100000 == 0) {
    print "Processed " NR " records.";
  }
  # Getting rid of dashes, colons, T and Z makes the timestamp fit into mktime perfectly.
  gsub(/[-:TZ]+/," ",$1);
  entry_timestamp = mktime($1);
  ipaddress = $4;
  split($16, urlparts, "?");
  # split the request into project and version
  gsub(/release-history\/\//,"release-history/",urlparts[1]);
  split(urlparts[1], urlfields, "/");
  project_name = urlfields[3];
  api_version = urlfields[4];
  split(urlparts[2],qsvars,"&");
  split(qsvars[1], site_query, "=");
  site_key = site_query[2];
  split(qsvars[2], version_query, "=");
   # Convert contrib dev releases to dev releases, not full releases.
   gsub(/\.[0-9].*%2B[0-9]+-dev$/,".x-dev", version_query[2]);
# Convert core dev releases to dev release.
   if (project_name == "drupal") {
     gsub(/\.[0-9]+-dev$/,".x-dev", version_query[2]);
   }
   project_version = version_query[2];
  # list variable is submodules in use for each project.
  split(qsvars[3], list_query, "=");
 # gsub(/%2C/, ",", list_query[2]);
  split(list_query[2], submodules, "%2C");
  # Save an array of table keys
  host_keys[ipaddress] = 1;
  if (host_table[ipaddress,"earliest"] == "") {
       host_table[ipaddress,"earliest"] = entry_timestamp;
  }
  host_table[ipaddress,"latest"] = entry_timestamp;
  host_table[ipaddress,"count"]++;
  #sometimes we do not get a site key
  if (length(site_key) == 0) {
    next;
  }
  host_site_keys[ipaddress,site_key] = 1;
  site_keys[site_key] = 1;
  if (host_site_table[ipaddress,site_key,"earliest"] == "") {
    host_site_table[ipaddress,site_key,"earliest"] = entry_timestamp;
  }
  if (site_table[site_key,"earliest"] == "") {
    site_table[site_key,"earliest"] = entry_timestamp;
  }
  host_site_table[ipaddress,site_key,"latest"] = entry_timestamp;
  site_table[site_key,"latest"] = entry_timestamp;
  host_site_table[ipaddress,site_key,"count"]++;
  site_table[site_key,"count"]++;
  # If we do not have a version, we'll just skip out on those
  # sometimes version isnt second, 'list' is, but no version.
  if (version_query[1] != "version" ) {
         next;
  }
  project_keys[site_key,project_name,project_version] = 1;
  if (site_projects_table[site_key,project_name,project_version,"earliest"] == "") {
           site_projects_table[site_key,project_name,project_version,"earliest"] = entry_timestamp;
  }
  # The assumption is that the log files are in descending order, and that
  # the last time we see a record is also the latest time we see it.
  site_projects_table[site_key,project_name,project_version,"latest"] = entry_timestamp;
  # update the counts
  site_projects_table[site_key,project_name,project_version,"count"]++;
  # Update the earliest/latest/counts for submodules
  for (submodule in submodules) {
    # Submodules will report the project in use in addition to submodules.
    # We dont need that.
    if (submodules[submodule] == project_name) {
      next;
    }
    submodule_keys[site_key,project_name,submodules[submodule]] = 1
    if (site_submodules_table[site_key,project_name,submodules[submodule],"earliest"] == "") {
      site_submodules_table[site_key,project_name,submodules[submodule],"earliest"] = entry_timestamp;
    }
    site_submodules_table[site_key,project_name,submodules[submodule],"latest"] = entry_timestamp;
    site_submodules_table[site_key,project_name,submodules[submodule],"count"]++;
  }
}
END {
 # Print out the hosts table:
  #Host Table
  #IP Address, IP First Seen, IP Last Seen, IP Count of visits
  for (ip_key in host_keys) {
      print ip_key,host_table[ip_key,"earliest"],host_table[ip_key,"latest"],host_table[ip_key,"count"] >> ("/data/stats/updatestats/sitemodel/" FILENAME ".host_table");
  }
  for (site_key in site_keys) {
    print site_key,site_table[site_key,"earliest"],site_table[site_key,"latest"],site_table[site_key,"count"] >> ("/data/stats/updatestats/sitemodel/" FILENAME ".site_table");
  }
  for (ip_site_key in host_site_keys) {
    split(ip_site_key, separated, SUBSEP);
    print separated[1],separated[2],host_site_table[ip_site_key,"earliest"],host_site_table[ip_site_key,"latest"],host_site_table[ip_site_key,"count"] >> ("/data/stats/updatestats/sitemodel/" FILENAME ".host_site_table");
  }
  for (project_version_key in project_keys) {
    split(project_version_key, separated, SUBSEP);
    print separated[1],separated[2],separated[3],site_projects_table[project_version_key,"earliest"],site_projects_table[project_version_key,"latest"],site_projects_table[project_version_key,"count"] >> ("/data/stats/updatestats/sitemodel/" FILENAME ".project_version_table");
  }
  for (submodule_site_key in submodule_keys) {
    split(submodule_site_key, separated, SUBSEP);
    print separated[1],separated[2],separated[3],site_submodules_table[submodule_site_key,"earliest"],site_submodules_table[submodule_site_key,"latest"],site_submodules_table[submodule_site_key,"count"] >> ("/data/stats/updatestats/sitemodel/" FILENAME ".submodule_table");
  }
}
