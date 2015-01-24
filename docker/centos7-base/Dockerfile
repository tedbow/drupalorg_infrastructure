FROM centos:centos7
MAINTAINER Archie Brentano <isntall.us@gmail.com>
RUN yum install -y \
  http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
RUN yum --nogpg install -y \
  file \
  hostname \
  htop \
  lbzip2 \
  lrzip \
  ncdu \
  openssh-server \
  openssh-clients \
  pigz \
  rsync \
  screen \
  tar \
  tree \
  vim \
  wget
RUN yum clean all
