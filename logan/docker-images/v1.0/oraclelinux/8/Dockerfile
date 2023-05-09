# # Copyright (c) 2023, Oracle and/or its affiliates.
# # Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

FROM container-registry.oracle.com/os/oraclelinux:8

USER root
WORKDIR /fluentd

# Environment variables
ENV PATH /fluentd/vendor/bundle/ruby/2.7.0/bin:$PATH
ENV GEM_PATH /fluentd/vendor/bundle/ruby/2.7.0:$GEM_PATH
ENV GEM_HOME /fluentd/vendor/bundle/ruby/2.7.0
# skip runtime bundler installation
ENV FLUENTD_DISABLE_BUNDLER_INJECTION 1
ENV TINI_VERSION=0.19.0

COPY Gemfile /fluentd/

# Install ruby 2.7 along with rubygems and bundler.
RUN dnf -y module enable ruby:2.7 \
 && dnf -y install --nodocs ruby ruby-libs \
 && dnf -y install --nodocs rubygems rubygem-openssl rubygem-psych \
 && dnf -y install --nodocs rubygem-bundler rubygem-io-console \
# Install development dependent packages for gems native installation
 && dnf -y install --nodocs gcc make redhat-rpm-config openssl ruby-devel gcc-c++ libtool libffi-devel bzip2 \
# Install Fluentd, it's dependencies along with other run time dependencies for OCI Logging Analytics Solution
 && bundle config silence_root_warning true \
 && bundle config --local path /fluentd/vendor/bundle \
 && bundle install --gemfile=/fluentd/Gemfile \
# Install tini, init for containers
 && curl -L -o /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini" \
 && curl -L -o /usr/local/bin/tini.asc "https://github.com/krallin/tini/releases/download/v$TINI_VERSION/tini.asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini \
 && chmod +x /usr/local/bin/tini \
# Install jemalloc
 && curl -L -o /tmp/jemalloc-4.5.0.tar.bz2 https://github.com/jemalloc/jemalloc/releases/download/4.5.0/jemalloc-4.5.0.tar.bz2 \
 && cd /tmp && tar -xjf jemalloc-4.5.0.tar.bz2 && cd jemalloc-4.5.0/ \
 && ./configure && make \
 && mv lib/libjemalloc.so.2 /usr/lib \
# Install hostname, required by fluent-plugin-rewrite-tag-filter
 && dnf -y install hostname \
# Remove all the development dependent packages
 && dnf -y remove gcc make redhat-rpm-config openssl ruby-devel gcc-c++ libtool libffi-devel bzip2 \
 && dnf clean all \
 && rm -rf /var/cache/dnf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

RUN mkdir -p /fluentd/etc /fluentd/plugins \
 && touch /fluentd/etc/disable.conf

# Environment variables
ENV FLUENTD_CONF="/fluentd/etc/fluent.conf"
ENV LD_PRELOAD="/usr/lib/libjemalloc.so.2"

COPY entrypoint.sh /fluentd/entrypoint.sh
# Give execution permission to entrypoint.sh
RUN ["chmod", "+x", "/fluentd/entrypoint.sh"]

# Overwrite ENTRYPOINT to run fluentd as root for /var/log / /var/lib
ENTRYPOINT ["tini", "--", "/fluentd/entrypoint.sh"]
