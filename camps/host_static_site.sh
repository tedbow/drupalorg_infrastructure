#!/bin/bash

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

###########################
# Script for Automatic hosting of static Camp sites in html
#
# Related: http://drupal.org/node/27882 - Creating a static archive of a Drupal site
# wget --recursive --no-clobber --page-requisites --html-extension \
# --convert-links --restrict-file-names=windows \
# --domains colorado2010.drupalcamp.org --no-parent colorado2010.drupalcamp.org/
#
# /etc/httpd/vhosts.d/drupalcamp.org.conf - has currently all the camp sites
#
#
# Contributor ricardoamaro
# Leads: 
# - This script will be running on a host that is not a webnode
# - It will be triggered by Jenkins
# - Takes 2 arguments: file + subdomain
#
###########################

if [[ "$2" == "" ]]; then
   echo -e "Usage:\nhost_static_site.sh {tgz file}/{remove} {subdomain}"
   exit 1
else
    FILE=$1 
    SUBDOMAIN=$2
fi

##### Web paths examples
#vhost_path="/etc/httpd/vhosts.d/static-camp-${SUBDOMAIN}.conf"
#web_path="/var/www/drupalcamp.org/${SUBDOMAIN}"

##### CHANGE HERE:
vhost_path="static-camp-${SUBDOMAIN}.conf"
web_path="/var/www/drupalcamp.org/${SUBDOMAIN}"

####START###
CWD=$(pwd)

# remove option #
if [[ "$1" == "remove" ]]; then
  echo "We are going to remove: ${SUBDOMAIN}.drupalcamp.org "
  echo "vhost_path = ${vhost_path}"
  echo "web_path   = ${web_path}"
  rm -rf ${web_path} ;
  rm ${vhost_path} ;
  echo "${SUBDOMAIN} Removed";
  exit 0 ;
fi


#Accept only a valid tgz 
CONTENTS=$(tar -tzvf ${FILE}) || (echo "Not a valid tgz. Aborting!!"; exit 1)

#Subdomain

#Check the tgz for .php files
if [[ `echo "${CONTENTS}" | grep .php` ]] ; then 
  echo "Aborting! We found some php files: " ; echo "$CONTENTS" ; 
  exit 1 ;
fi

#Check for an index.htm/l in the tgz root
if [[ `echo "$CONTENTS" | grep " index.htm"` ]] ; then
    echo "" ;
else 
    echo "No root index.html found. Aborting!!" ;
    exit 1;
fi


#echo "${FILE} contents will be used to populate the site: ${SUBDOMAIN}.drupalcamp.org"
#echo "vhost_path = ${vhost_path}"
#echo "web_path   = ${web_path}"
#echo "$CONTENTS" | grep "index.htm" | head -n5

###DECOMPRESS###
rm -rf ${web_path}
mkdir -p ${web_path}
cd ${web_path}
tar xzf ${FILE} 

#find and remove .htaccess + *.php and any other problematic file
find "${web_path}/." -type f -name "*.php" -exec rm -f {} \;
find "${web_path}/." -type f -name ".htaccess" -exec rm -f {} \;


# Write the vhost
cd ${CWD}

VHOSTFILE="
<VirtualHost *:8080>
   ServerName ${SUBDOMAIN}.drupalcamp.org
 
    DocumentRoot ${web_path}/
 
    <Directory ${web_path}/>
        Options FollowSymLinks
        AllowOverride None
        Order Allow,Deny
        Allow from all
    </Directory>
 
    CustomLog \"|/usr/sbin/cronolog /var/log/apache2/drupalcamp.org/transfer/%Y%m%d.log\" combined
    ErrorLog \"|/usr/sbin/cronolog /var/log/apache2/drupalcamp.org/error/%Y%m%d.log\"
</VirtualHost> " 

echo "${VHOSTFILE}"
echo "${VHOSTFILE}" > "${vhost_path}"


#echo "All done!"
#time curl -Is ${SUBDOMAIN}.drupalcamp.org

exit 0
