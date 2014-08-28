FROM isntall/centos6:base
MAINTAINER Archie Brentano <isntall.us@gmail.com>
ADD files/MariaDB.repo /etc/yum.repos.d/MariaDB.repo
RUN rpm --import http://yum.mariadb.org/RPM-GPG-KEY-MariaDB
RUN yum history new
ADD files/my.cnf /etc/my.cnf
RUN yum install -y \
  MariaDB-server \
  MariaDB-client \
  MySQL-python 
RUN yum clean all
EXPOSE 3306

