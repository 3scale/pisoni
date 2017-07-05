FROM 3scale/docker:dev-2.3.1
MAINTAINER Toni Reina <toni@3scale>

WORKDIR /tmp/core/

ADD Gemfile /tmp/core/
ADD lib/3scale/core/version.rb /tmp/core/lib/3scale/core/
ADD 3scale_core.gemspec /tmp/core/

RUN chown -R ruby: /tmp/core/

USER ruby
RUN bundle install

USER root
RUN rm -rf /tmp/core/

WORKDIR /home/ruby/core/
ADD . /home/ruby/core/
RUN chown -R ruby:users /home/ruby/core/

USER ruby
RUN bundle install
