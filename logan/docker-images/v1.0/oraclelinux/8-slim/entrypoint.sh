# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

#!/usr/bin/env sh

bundle exec fluentd -c ${FLUENTD_CONF} -p /fluentd/plugins --gemfile /fluentd/Gemfile ${FLUENTD_OPT}
