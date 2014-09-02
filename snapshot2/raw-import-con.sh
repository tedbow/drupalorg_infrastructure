#!/bin/bash
set -uex

rm -rf /var/lib/mysql/*
mysql_install_db
service mysql start
#mysql -uroot -e "DROP DATABASE IF EXISTS raw_import;"
mysql -uroot -e "CREATE DATABASE raw_import;"
mysql -uroot -hlocalhost raw_import < /var/dumps/raw/drupal_database_snapshot.raw-current.sql
service mysql stop

