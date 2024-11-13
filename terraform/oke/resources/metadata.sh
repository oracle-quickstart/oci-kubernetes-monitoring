#!/bin/bash
# Copyright (c) 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.
set -e
curl -H "Authorization: Bearer Oracle" -sL http://169.254.169.254/opc/v2/instance/ | jq .regionInfo
# example output =>
# echo '{
#   "realmDomainComponent": "oraclecloud.com",
#   "realmKey": "oc1",
#   "regionIdentifier": "us-phoenix-1",
#   "regionKey": "PHX"
# }'