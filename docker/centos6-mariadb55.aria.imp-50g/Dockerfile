FROM isntall/centos6-base
MAINTAINER Archie Brentano <isntall.us@gmail.com>
ADD files/MariaDB.repo /etc/yum.repos.d/MariaDB.repo
RUN rpm --import http://yum.mariadb.org/RPM-GPG-KEY-MariaDB
RUN rpm --import https://www.percona.com/downloads/RPM-GPG-KEY-percona
RUN yum history new
ADD files/my-innodb.cnf /etc/my-innodb.cnf
ADD files/my-ariadb.cnf /etc/my-ariadb.cnf
RUN cp /etc/my-innodb.cnf /etc/my.cnf
RUN mkdir /var/lib/mysql
RUN yum install -y \
  MariaDB-server \
  MariaDB-client \
  MySQL-python \
  http://www.percona.com/redir/downloads/XtraBackup/XtraBackup-2.1.9/RPM/rhel6/x86_64/percona-xtrabackup-2.1.9-744.rhel6.x86_64.rpm \
  http://repo.percona.com/centos/6/RPMS/x86_64/qpress-11-1.el6.x86_64.rpm
RUN yum clean all
EXPOSE 3306

