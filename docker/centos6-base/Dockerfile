FROM centos:centos6
MAINTAINER Archie Brentano <isntall.us@gmail.com>
RUN rpm --import https://fedoraproject.org/static/0608B895.txt
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
RUN yum history new
RUN yum install -y \
  http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum install -y \
  bzip2 \
  file \
  htop \
  lrzip \
  ncdu \
  openssh-server \
  openssh-clients \
  pbzip2 \
  pigz \
  rsync \
  screen \
  tar \
  tree \
  vim \
  wget
