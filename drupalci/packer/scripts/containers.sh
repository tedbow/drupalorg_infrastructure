#!/bin/bash -eux

# TODO: this should iterate over containers that are stored at dockerhub in the drupalci account.
# This would require using their API somehow, which might mean that we'd have to have a

docker pull drupalci/mysql-5.5
docker pull drupalci/pgsql-9.1

#pull new db containers
docker pull drupalci/db-mysql-5.5:dev
docker pull drupalci/db-mysql-5.5:production
docker pull drupalci/db-pgsql-9.1:dev
docker pull drupalci/db-pgsql-9.1:production
#pull php containers
docker pull drupalci/php-5.3.29-apache:dev
docker pull drupalci/php-5.3.29-apache:production
docker pull drupalci/php-5.4.45-apache:dev
docker pull drupalci/php-5.4.45-apache:production
#docker pull drupalci/php-5.5.9-apache:dev
#docker pull drupalci/php-5.5.9-apache:production
docker pull drupalci/php-5.5.38-apache:dev
docker pull drupalci/php-5.5.38-apache:production
docker pull drupalci/php-5.6-apache:dev
docker pull drupalci/php-5.6-apache:production
docker pull drupalci/php-5.6.x-apache:dev
docker pull drupalci/php-5.6.x-apache:production
docker pull drupalci/php-7.0-apache:dev
docker pull drupalci/php-7.0-apache:production
docker pull drupalci/php-7.0.x-apache:dev
docker pull drupalci/php-7.0.x-apache:production
docker pull drupalci/php-7.1-apache:dev
docker pull drupalci/php-7.1-apache:production
docker pull drupalci/php-7.1.x-apache:dev
docker pull drupalci/php-7.1.x-apache:production

# new containers.
#for CONTAINER in $(find ./containers -name Dockerfile | grep -v 'dev' | awk -F"/" '{print $4}');
#do
#   docker pull drupalci/${CONTAINER};
#done
