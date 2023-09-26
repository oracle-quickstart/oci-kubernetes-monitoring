# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

### Referred version from fluentd-kubernetes-daemonset gitgub repo ###

FROM fluent/fluentd:v1.14.3-debian-1.0

USER root
WORKDIR /home/fluent
ENV PATH /fluentd/vendor/bundle/ruby/2.7.0/bin:$PATH
ENV GEM_PATH /fluentd/vendor/bundle/ruby/2.7.0
ENV GEM_HOME /fluentd/vendor/bundle/ruby/2.7.0
# skip runtime bundler installation
ENV FLUENTD_DISABLE_BUNDLER_INJECTION 1

COPY Gemfile* /fluentd/
RUN buildDeps="sudo make gcc g++ libc-dev libffi-dev" \
  runtimeDeps="" \
      && apt-get update \
     && apt-get upgrade -y \
     && apt-get install \
     -y --no-install-recommends \
     $buildDeps $runtimeDeps net-tools \
    && gem install bundler --version 2.1.4 \
    && bundle config silence_root_warning true \
    && bundle config --local path /fluentd/vendor/bundle \
    && bundle install --gemfile=/fluentd/Gemfile \
    && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
    && gem sources --clear-all \
    && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

RUN touch /fluentd/etc/disable.conf

COPY entrypoint.sh /fluentd/entrypoint.sh

# Environment variables
ENV FLUENTD_CONF="/fluentd/etc/fluent.conf"

# Give execution permission to entrypoint.sh
RUN ["chmod", "+x", "/fluentd/entrypoint.sh"]

# Overwrite ENTRYPOINT to run fluentd as root for /var/log / /var/lib
ENTRYPOINT ["tini", "--", "/fluentd/entrypoint.sh"]
