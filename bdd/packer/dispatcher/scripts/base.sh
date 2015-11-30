#!/bin/bash -eux

pkg update
pkg upgrade -y
pkg install -y jenkins-lts bash vim the_silver_searcher zsh gnu-utils puppet
