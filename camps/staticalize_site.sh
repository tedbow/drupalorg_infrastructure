#!/bin/bash

# Exit immediately on uninitialized variable or error, and print each command.
#set -uex

###########################
# Script for Automatic create static Camp sites in html into a tgz
#
# Related: http://drupal.org/node/27882 - Creating a static archive of a Drupal site
# wget --recursive --no-clobber --page-requisites --html-extension \
# --convert-links --restrict-file-names=windows \
# --domains colorado2010.camps.drupal.org --no-parent colorado2010.camps.drupal.org/
#
# Contributor ricardoamaro
# Leads: 
# https://docs.google.com/spreadsheet/ccc?key=0Ao8Y0KepJTHzdDB3YXJWaFk2QTRUV3dZVUhfbThWaUE#gid=0
###########################

if [[ "$1" == "" ]]; then
   echo -e "Usage:\nstaticalize_site.sh {domain} {wget/httrack}"
   echo -e "\nwget is the default option"
   exit 1
else
    SITE=$1 
fi

echo "This script will create a tgz version of ${SITE} on ~/static/${SITE}/"

rm -rf ~/static/${SITE} ~/static/index.html ~/static/hts* ~/static/*.gif
mkdir -p ~/static/${SITE}/
cd ~/static

echo "Crawling..."

if [[ "$2" == "httrack" ]]; then 
   httrack http://${SITE}  -w -O . -%v --robots=0 -c1 -%e0
   else
   wget --mirror -p --html-extension -e robots=off --base=./ -k -P ./ http://${SITE}
fi

echo "Going to tgz ~/static/${SITE}/"
sleep 5

cd ~/static/${SITE}/
tar czvf ~/static/${SITE}.tgz *
echo "done ${SITE}"
ls -lah ~/static/${SITE}.tgz

exit 0

