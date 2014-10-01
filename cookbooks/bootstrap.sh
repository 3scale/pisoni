#!/usr/bin/env bash

# Extra repositories
apt-get install -y python-software-properties
apt-add-repository ppa:brightbox/ruby-ng
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list.d/10gen.list
apt-get update

# Basic config
echo "StrictHostKeyChecking no" > /home/vagrant/.ssh/config
echo "Europe/Madrid" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Basic tools
apt-get install -y git

# Ruby 2.1
apt-get -y install ruby rubygems ruby-switch
apt-get -y install ruby2.1 ruby2.1-dev
ruby-switch --set ruby2.1

# Dependencies
apt-get install -y libxslt-dev libxml2-dev
#apt-get install -y mongodb-10gen

# Application setup
gem install bundler rake

# Instruct the local backend used on ci mode to use our Redis instance
# (note that core and backend use different dbs within Redis)
su - vagrant -c "echo ThreeScale::Backend.configure { \|c\| c.redis.proxy=\'localhost:6379\' } > ~/.3scale_backend.conf"

su - vagrant -c "echo export LC_ALL=en_US.UTF8 >> ~/.bashrc"
