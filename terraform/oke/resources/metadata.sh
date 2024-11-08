#!/bin/bash
set -e
curl -H "Authorization: Bearer Oracle" -sL http://169.254.169.254/opc/v2/instance/ | jq .regionInfo
# example output =>
# echo '{
#   "realmDomainComponent": "oraclecloud.com",
#   "realmKey": "oc1",
#   "regionIdentifier": "us-phoenix-1",
#   "regionKey": "PHX"
# }'