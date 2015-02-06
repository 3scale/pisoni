FROM 3scale/docker:dev-2.1.5
MAINTAINER Toni Reina <toni@3scale>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 136221EE520DDFAF0A905689B9316A7BC7917B12 \
&& echo 'deb http://ppa.launchpad.net/chris-lea/redis-server/ubuntu precise main' > /etc/apt/sources.list.d/redis-server.list \
&& apt-get -y -q update \
&& apt-get -y -q install redis-server=2:2.8.19-1chl1~precise1

WORKDIR /opt/core/
ADD . /opt/core

ADD docker/ssh /home/ruby/.ssh
RUN chown -R ruby:ruby /home/ruby/.ssh
