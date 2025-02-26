# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

### Build the docker image using multi-stage build

## To build/install all the dependencies

FROM container-registry.oracle.com/os/oraclelinux:8-slim AS builder

USER root
WORKDIR /fluentd

# Environment variables
ENV PATH /fluentd/vendor/bundle/ruby/3.3/bin:$PATH
ENV GEM_PATH /fluentd/vendor/bundle/ruby/3.3:$GEM_PATH
ENV GEM_HOME /fluentd/vendor/bundle/ruby/3.3
# skip runtime bundler installation
ENV FLUENTD_DISABLE_BUNDLER_INJECTION 1

COPY Gemfile* /fluentd/
COPY tcpconnect.* /fluentd/
COPY tcp-monitor /usr/local/bin/

# Install ruby, ruby-libs along with rubygems and bundler.
RUN microdnf -y module enable ruby:3.3 \
# Install ruby and ruby-libs, disabling week dependencies
 && microdnf -y install --setopt=install_weak_deps=0 --nodocs ruby ruby-libs \
# Install rubygems (it's dependencies rubygem-openssl rubygem-psych), disabling week dependencies
 && microdnf -y install --setopt=install_weak_deps=0 --nodocs rubygems \
 && gem install bundler -v 2.5.16 \
# Install development dependent packages for gems native installation
 && microdnf --enablerepo ol8_codeready_builder -y install --nodocs gcc make redhat-rpm-config openssl ruby-devel gcc-c++ libtool libffi-devel bzip2 git libyaml-devel zlib elfutils-libelf-devel which clang llvm \
# Install Fluentd, it's dependencies along with other run time dependencies for OCI Logging Analytics Solution
 && bundle config silence_root_warning true \ 
 && bundle config --local path /fluentd/vendor/bundle \
 && bundle config --global jobs 9 \
 && bundle install --gemfile=/fluentd/Gemfile \
# Install tini, init for containers (from EPEL repo)
 && microdnf -y install --setopt=install_weak_deps=0 --nodocs oracle-epel-release-el8 \
 && microdnf -y install --nodocs tini-0.19.0 \
# Install jemalloc (custom make with no docs)
 && cd /tmp && ls /tmp \
 && git clone --depth 1 -b 5.3.0 https://github.com/jemalloc/jemalloc.git && cd jemalloc/ \  
 && ./autogen.sh && make && make install_bin install_include install_lib \
 && mv lib/libjemalloc.so.2 /usr/lib \
 # Install libbpf-tools from bcc
 && cd /tmp && ls /tmp \
 && git clone -b v0.29.1 --depth 1 https://github.com/iovisor/bcc.git && cd bcc/ && git submodule update --init --recursive \
 && cd libbpf-tools/ && cp /fluentd/tcpconnect.* ./ && make  \
 && mv ./tcpconnect /usr/bin/ \
 && rm /fluentd/tcpconnect.* \
 && cd /fluentd/

## To build the final docker image

FROM container-registry.oracle.com/os/oraclelinux:8-slim

USER root
WORKDIR /fluentd

# Environment variables
ENV PATH /fluentd/vendor/bundle/ruby/3.3/bin:$PATH
ENV GEM_PATH /fluentd/vendor/bundle/ruby/3.3:$GEM_PATH
ENV GEM_HOME /fluentd/vendor/bundle/ruby/3.3
# skip runtime bundler installation
ENV FLUENTD_DISABLE_BUNDLER_INJECTION 1

# Install ruby, ruby-libs along with rubygems and bundler.
RUN microdnf -y module enable ruby:3.3 \
# Install ruby and ruby-libs, disabling week dependencies
 && microdnf -y install --setopt=install_weak_deps=0 --nodocs ruby ruby-libs \ 
# Install rubygems (it's dependencies rubygem-openssl rubygem-psych), disabling week dependencies
 && microdnf -y install --setopt=install_weak_deps=0 --nodocs rubygems \ 
# Install development packages needed for tcp_monitor
# && microdnf --enablerepo ol8_codeready_builder -y install --nodocs gcc make redhat-rpm-config openssl ruby-devel gcc-c++ libtool libffi-devel bzip2 libyaml-devel zlib elfutils-libelf-devel which clang llvm \
 && gem install bundler -v 2.5.16 \
 && bundle config --local path /fluentd/vendor/bundle \
# clear caches
 && microdnf clean all \
 && rm -rf /var/cache/dnf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem  

# Copy binaries (tini & jemallco) and rubygems bundler environment from build stage
COPY --from=builder /fluentd /fluentd
COPY --from=builder /usr/bin/tini /usr/bin/tini
COPY --from=builder /usr/lib/libjemalloc.so.2 /usr/lib/libjemalloc.so.2
COPY --from=builder /usr/bin/tcpconnect /usr/bin/tcpconnect
COPY --from=builder /usr/local/bin /usr/local/bin

RUN chmod +x /usr/local/bin/tcp-monitor
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
