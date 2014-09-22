FROM isntall/centos6-mariadb.aria
MAINTAINER Archie Brentano <isntall.us@gmail.com>
RUN rpm --import https://www.percona.com/downloads/RPM-GPG-KEY-percona
RUN yum history new
RUN yum install -y rsync 
  http://www.percona.com/redir/downloads/XtraBackup/LATEST/binary/redhat/6/x86_64/percona-xtrabackup-2.2.4-5004.el6.x86_64.rpm \
  http://repo.percona.com/centos/6/RPMS/x86_64/qpress-11-1.el6.x86_64.rpm
ADD files/my.cnf /etc/my.cnf
EXPOSE 3306

