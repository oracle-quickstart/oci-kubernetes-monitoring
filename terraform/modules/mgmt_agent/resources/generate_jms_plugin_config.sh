#!/bin/bash
# Copyright (c) 2026, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# External script to get the JMS agent installer configuration:
# Prints JSON on stdout: {"content": "<base64-encoded-installer-config-content>"}
# Fails gracefully with an error key in JSON if any error occurs.

set -e

INPUT="$(cat)"
FLEET_OCID=$(echo "$INPUT" | jq -r '.fleet_ocid // empty')
INSTALL_KEY=$(echo "$INPUT" | jq -r '.install_key // empty')

if [[ -z "$FLEET_OCID" || -z "$INSTALL_KEY" ]]; then
  echo '{"error": "Missing fleet_ocid or install_key input."}'
  exit 1
fi

if ! command -v oci >/dev/null 2>&1; then
  echo '{"error": "OCI CLI not available on path."}'
  exit 1
fi

CONFIG_CONTENT=$(oci jms agent-installer-summary generate-agent-installer-configuration \
  --fleet-id "$FLEET_OCID" \
  --install-key-id "$INSTALL_KEY" \
  --agent-type "OCMA" \
  --query "data" \
  --raw-output \
  --file - 2>&1
)
STATUS=$?

if [[ $STATUS != 0 ]]; then
  ERROR_MSG=$(echo "$CONFIG_CONTENT" | jq -Rs .)
  echo "{\"error\": $ERROR_MSG}"
  exit 1
fi

jq -n --arg content "$CONFIG_CONTENT" '{"content": $content}'
