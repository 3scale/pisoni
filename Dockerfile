FROM 3scale/docker:dev-2.1.6
MAINTAINER Toni Reina <toni@3scale>

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 136221EE520DDFAF0A905689B9316A7BC7917B12 \
&& echo 'deb http://ppa.launchpad.net/chris-lea/redis-server/ubuntu precise main' > /etc/apt/sources.list.d/redis-server.list \
&& apt-get -y -q update \
&& apt-get -y -q install redis-server

WORKDIR /tmp/core/

ADD Gemfile /tmp/core/
ADD lib/3scale/core/version.rb /tmp/core/lib/3scale/core/
ADD 3scale_core.gemspec /tmp/core/

RUN bundle config --global without ''

ADD docker/ssh /home/ruby/.ssh
RUN chown -R ruby:ruby /home/ruby/.ssh /tmp/core

RUN su - ruby -c "cd /tmp/core && bundle install"
