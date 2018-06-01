FROM quay.io/3scale/pisoni-ci:latest
MAINTAINER Alejandro Martinez Ruiz <amr@redhat.com>

ARG RUBY_VERSIONS
RUN test "x${RUBY_VERSIONS}" = "x" || ruby_versions ${RUBY_VERSIONS}

COPY Gemfile *.gemspec .ruby-* /tmp/app/
COPY lib/3scale/core/version.rb /tmp/app/lib/3scale/core/
RUN sudo chown -R "$(id -un)": /tmp/app \
    && cd /tmp/app \
    && bundle_install_rubies \
    && rm -rf /tmp/app

CMD ["/bin/bash", "-c", "bundle_install_rubies ${TEST_RUBIES} && script/wait_for_start script/test"]
