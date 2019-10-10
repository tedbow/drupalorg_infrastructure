#!/usr/bin/mawk -f

function basename(file, a, n) {
    n = split(file, a, "/")
    return a[n]
  }

 BEGIN {
        FS=",";
        OFS=",";
        processname = basename(ARGV[1]);
        split(processname,components,/\+/);
        master_file = "/data/stats/updatestats/sitemodel/master/module/" components[1] "_module_table.csv";
        system("touch " master_file)
        while (getline < master_file)
                {
                    split($0,hostrec,",");
                    hashkey = hostrec[1]","hostrec[2]","hostrec[3]","hostrec[4]","hostrec[5];
                    firstseen = hostrec[6];
                    lastseen = hostrec[7];
                    seencount = hostrec[8];

                    firstseens[hashkey] = firstseen;
                    lastseens[hashkey] = lastseen;
                    seencounts[hashkey] = seencount;
                    recordages[hashkey] = lastseen - firstseen;

                }
        close(master_file);

        while (getline < "/usr/local/drupal-infrastructure/stats/NG/drupalorg_projects.csv")
        {
            split($0,ft,",");
            project_machine_name=ft[1];
            project_nid=ft[2];
            project_nodes[ft[1]] = ft[2];
        }
        close("/usr/local/drupal-infrastructure/stats/NG/drupalorg_projects.csv");
  }


  {

   hashkey = $1","$2","$3","$4","$5;
   firstseen = $6;
   lastseen = $7;
   seencount = $8;

   if (project_nodes[$2] == "") {
     skipped++;
     next;
   }

   {
     # If we've never seen this key before, its a new record
     if (firstseens[hashkey] == "") {
          firstseens[hashkey] = firstseen;
          lastseens[hashkey] = lastseen;
          seencounts[hashkey] = seencount;
          recordages[hashkey] = lastseen - firstseen;
          next;
     }
     # Otherwise we have a record, and need to update the counts and dates.
     if (firstseens[hashkey] > firstseen) {
       firstseens[hashkey] = firstseen;
     }
     if (lastseens[hashkey] < lastseen) {
            lastseens[hashkey] = lastseen;
     }
     seencounts[hashkey] += seencount;
     recordages[hashkey] = lastseens[hashkey] - firstseens[hashkey];
   }
 }

 END {
   system("rm -rf " master_file);
   for (key in firstseens) {
      print key, firstseens[key],lastseens[key],seencounts[key], recordages[key] >> (master_file);
   }

 }
