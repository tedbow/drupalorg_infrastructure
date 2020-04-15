#!/usr/bin/env -S mawk -f

#1543622448,LefTa9Yuz_0C5o_PPrsbUWrz9n9fYLsabPN-Nhd2TnE,8.x,acquia_lift,8.x-3.6,acquia_lift|acquia_lift_inspector ,8.5.3,6.3.3,7.47.0,7.1.22,
function basename(file, a, n) {
    n = split(file, a, "/")
    return a[n]
  }

 BEGIN {
        FS=",";
        OFS=",";
        }

  {

   entry_timestamp = $1;
   site_key = $2;
   maj_api = $3;
   project_name = $4;
   project_version = $5;
   module_list = $6;
   d8_drupal_version = $7
   guzzle_version = $8
   curl_version = $9
   php_version = $10
   php_extra = $11

  split(module_list, modules, "|");
   #sometimes we do not get a site key
   if (length(site_key) == 0) {
     next;
   }

   # The assumption is that the log files are in descending order, and that
   # the last time we see a record is also the latest time we see it.
   # update the counts

   # Unique Site Key Table.
   site_keys[site_key] = 1;

   if (site_table[site_key,"earliest"] == "") {
     site_table[site_key,"earliest"] = entry_timestamp;
   }

   if (site_table[site_key,"earliest"] > entry_timestamp) {
     site_table[site_key,"earliest"] = entry_timestamp;
   }
   if (site_table[site_key,"latest"] < entry_timestamp) {
     site_table[site_key,"latest"] = entry_timestamp;
   }
   site_table[site_key,"count"]++;
   site_table[site_key,"maj_api"] = maj_api;

   # Populate the client data
   if (php_version != "") {

   php_keys[site_key,php_version] = 1;
   if (php_table[site_key,php_version,"earliest"] == "") {
     php_table[site_key,php_version,"earliest"] = entry_timestamp;
   }
   if (php_table[site_key,php_version,"earliest"] > entry_timestamp) {
     php_table[site_key,php_version,"earliest"] = entry_timestamp;
   }
   if (php_table[site_key,php_version,"latest"] < entry_timestamp) {
     php_table[site_key,php_version,"latest"] = entry_timestamp;
   }
   php_table[site_key,php_version,"count"]++;

   php_table[site_key,php_version,"guzzle"] = guzzle_version;
   php_table[site_key,php_version,"php_extra"] = php_extra;
   php_table[site_key,php_version,"curl"] = curl_version;
   }

   if (d8_drupal_version != "") {
   drupal8_keys[site_key,d8_drupal_version] = 1;
       if (d8_table[site_key,d8_drupal_version,"earliest"] == "") {
        d8_table[site_key,d8_drupal_version,"earliest"] = entry_timestamp;
       }
       if (d8_table[site_key,d8_drupal_version,"earliest"] > entry_timestamp) {
         d8_table[site_key,d8_drupal_version,"earliest"] = entry_timestamp;
       }
       if (d8_table[site_key,d8_drupal_version,"latest"] < entry_timestamp) {
         d8_table[site_key,d8_drupal_version,"latest"] = entry_timestamp;
       }
       d8_table[site_key,d8_drupal_version,"count"]++;
   }


   # Site key to Project Key table.
   site_project_keys[site_key,project_name,project_version] = 1;
   if (site_projects_table[site_key,project_name,project_version,"earliest"] == "") {
     site_projects_table[site_key,project_name,project_version,"earliest"] = entry_timestamp;
   }
   if (site_projects_table[site_key,project_name,project_version,"earliest"] > entry_timestamp) {
     site_projects_table[site_key,project_name,project_version,"earliest"] = entry_timestamp;
   }
   if (site_projects_table[site_key,project_name,project_version,"latest"] < entry_timestamp) {
     site_projects_table[site_key,project_name,project_version,"latest"] = entry_timestamp;
   }
   site_projects_table[site_key,project_name,project_version,"count"]++;
   site_projects_table[site_key,project_name,project_version,"maj_api"] = maj_api;


   # Site key to project to modules table.
   for (module in modules) {

     module_keys[site_key,project_name,project_version,modules[module]] = 1
     if (site_modules_table[site_key,project_name,project_version,modules[module],"earliest"] == "") {
       site_modules_table[site_key,project_name,project_version,modules[module],"earliest"] = entry_timestamp;
     }
     if (site_modules_table[site_key,project_name,project_version,modules[module],"earliest"] > entry_timestamp) {
       site_modules_table[site_key,project_name,project_version,modules[module],"earliest"] = entry_timestamp;
     }
     if (site_modules_table[site_key,project_name,project_version,modules[module],"latest"] < entry_timestamp) {
       site_modules_table[site_key,project_name,project_version,modules[module],"latest"] = entry_timestamp;
     }
     site_modules_table[site_key,project_name,project_version,modules[module],"count"]++;
     site_modules_table[site_key,project_name,project_version,modules[module],"maj_api"] = maj_api;
   }

 }

 END {
  # Print out the site table:
   #Site Table
   #IP Address, IP First Seen, IP Last Seen, IP Count of visits
   for (site_key in site_keys) {
     print site_key,site_table[site_key,"maj_api"],site_table[site_key,"earliest"],site_table[site_key,"latest"],site_table[site_key,"count"] >> ("/data/stats/updatestats/sitemodel/processing/site/" basename(FILENAME) ".site_table");
   }

   for (php_site_key in php_keys) {
     split(php_site_key, p_separated, SUBSEP);
     print p_separated[1],p_separated[2],php_table[php_site_key,"guzzle"],php_table[php_site_key,"curl"],php_table[php_site_key,"php_extra"],php_table[php_site_key,"earliest"],php_table[php_site_key,"latest"],php_table[php_site_key,"count"] >> ("/data/stats/updatestats/sitemodel/processing/php/" basename(FILENAME) ".php_table");
   }
   for (d8_site_key in drupal8_keys) {
     split(d8_site_key, d_separated, SUBSEP);
     print d_separated[1],d_separated[2],d8_table[d8_site_key,"earliest"],d8_table[d8_site_key,"latest"],d8_table[d8_site_key,"count"] >> ("/data/stats/updatestats/sitemodel/processing/drupal/" basename(FILENAME) ".drupal_table");
   }

   for (project_site_key in site_project_keys) {
     split(project_site_key, pj_separated, SUBSEP);
     print pj_separated[1],pj_separated[2],site_projects_table[project_site_key,"maj_api"],pj_separated[3],site_projects_table[project_site_key,"earliest"],site_projects_table[project_site_key,"latest"],site_projects_table[project_site_key,"count"] >> ("/data/stats/updatestats/sitemodel/processing/project/" basename(FILENAME) ".project_table");
   }

   for (module_site_key in module_keys) {
     split(module_site_key, m_separated, SUBSEP);
     print m_separated[1],m_separated[2],m_separated[4],site_modules_table[module_site_key,"maj_api"],m_separated[3],site_modules_table[module_site_key,"earliest"],site_modules_table[module_site_key,"latest"],site_modules_table[module_site_key,"count"] >> ("/data/stats/updatestats/sitemodel/processing/module/" basename(FILENAME) ".module_table");
   }

 }
