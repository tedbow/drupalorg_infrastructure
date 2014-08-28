FROM centos:centos7
MAINTAINER Archie Brentano <isntall.us@gmail.com>
RUN yum install -y http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-0.2.noarch.rpm
RUN yum update -y && yum install -y \
  bzip2 \
  htop \
  lrzip \
  mariadb-server \
  mariadb \
  MySQL-python \
  openssh-server \
  openssh-clients \
  screen \
  vim \
  wget

EXPOSE 3306

