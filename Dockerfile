FROM quay.io/centos7/ruby-27-centos7

USER 1001

WORKDIR /opt/app

COPY --chown=1001:1001 ./ /opt/app

RUN bundle config set --local path ./vendor/bundle && \
    bundle install --jobs $(grep -c processor /proc/cpuinfo) --retry=5

CMD bundle exec rake test
