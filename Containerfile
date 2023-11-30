FROM registry.access.redhat.com/ubi8/ruby-27
MAINTAINER Daria Mayorova <dmayorova@redhat.com>

USER default
WORKDIR ${APP_ROOT}

COPY --chown=default:root  Gemfile *.gemspec ./
COPY lib/3scale/core/version.rb ${APP_ROOT}/lib/3scale/core/

RUN bundle config set --local path 'vendor/bundle' \
    && bundle install --jobs $(grep -c processor /proc/cpuinfo) --retry 3

COPY --chown=default:root . .

CMD ["/bin/bash", "-c", "script/wait_for_start script/test"]
