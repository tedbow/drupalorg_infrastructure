#!/usr/bin/gawk -f
BEGIN { FS = "|"; OFS=","; print ARGV[1] }

#Blocked Users
 /status toggled to [un]*block/ {

    split($5,a,"/"); #a[6] is the blocked userid
    split($6,b,"/"); #b[5] is the username
    l=split($9,c," "); #c is the status message (blocked or unblocked)

    #$2 = timestamp
    #$7 = blocking user
    print strftime("%Y-%m-%d",$2), $2, $7, a[6], b[5], substr(c[l],0, length(c[l])-1) >> "wdstats_blocked_users"
}

#Not a Spammer
/role 36 toggled to/ {

    split($5,a,"/"); #a[6] is the blocked userid
    split($6,b,"/"); #b[5] is the username

    # $2 = timestamp
    # $7 = blocking user
    print strftime("%Y-%m-%d",$2), $2, $7, a[6], b[5], "Not a Spammer" >> "wdstats_not_a_spammer"

 }

#Deleted Nodes from Solr - mostly congruent with deleted nodes

/Deleted documents from index with query id:"sh0zn1\/node/  && !/project-release/  && !/\/edit\|/ {

    split($9,a,"\"");
    split(a[2],b,"/"); #c is the status message (blocked or unblocked)

    # $2 = timestamp
    # $7 = deleting user
    # $5 =
    # b[3] = nid
    print strftime("%Y-%m-%d",$2), $2, $7, $5, b[3], "Node Deleted" >> "wdstats_deleted_nodes"
}

/Deleted user/ && /www.drupal.org/ {

    l=split($9,a,": ");
    #split(a[2],b,"/"); #c is the status message (blocked or unblocked)

    # $2 = timestamp
    # $7 = deleting user
    # $5 =
    # a[2] = user id
    print strftime("%Y-%m-%d",$2), $2, $7, $5, substr(a[2],0,length(a[2])-2), "User Deleted" >> "wdstats_deleted_users"
}

#New Users

/New user:/ {
 split($9,a,"(");
 sub("New user: ", "", a[1]);
 gsub(/ $/,"",a[1]);
 gsub(/\).$/,"",a[2]);
 split(a[2],e,"@");
 # $2 = timestamp
 # $4 = ip address
 # a[1] = username
 # a[2] = email
 # e[2] = email domain
 print strftime("%Y-%m-%d",$2),$2,$4,a[1],a[2],e[2] >> "wdstats_new_users"
}

# Honeypot Users given penalties
#
# These are users who were granted extra time from honeypot. Excludes the user register form.

/\|honeypot\|/ && !/user_register_form/ && /Spammer/ {
  l=split($9,uname,"(");
  gsub(/Spammer /,"",uname[1]);

  # $2 = timestamp
  # $4 = ip address
  # $7 = uid
  # $uname[1] = username

  split(uname[2],time,"and ");
  gsub(/ extra time./,"", time[2]);
  print strftime("%Y-%m-%d",$2),$2,$4,$7,substr(uname[1],0,length(uname[1])-1), time[2], "User Penalized" >> "wdstats_honeypot_penalized"

}

# Honeypot user registrations blocked
# The 'form field filled in" is almost always accompanied by an identical minimum time issue.

/\|honeypot\|/ && /user_register_form/ && /minimum/ {
  print strftime("%Y-%m-%d",$2),$2,$4, "Honeypot User Registration Blocked" >> "wdstats_honeypot_registration_blocks"
}
