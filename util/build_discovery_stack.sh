#!/bin/bash

# Fail at first error
set -e

# Helper Functions

function log {
        echo -e "$(date) $1"
}

function error_and_exit {
    log "$1"
    exit 1
}

function abspath    {
    relative_path=$1
    cd "$relative_path" || error_and_exit "Absolute path conversion failed: $relative_path"
    pwd
}

UTIL_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR="$UTIL_DIR/.."
ROOT_DIR=$(abspath "$ROOT_DIR") # Convert to absolute path
STACK_DIR=$ROOT_DIR/service-discovery-stack

BUILD_DIR="$ROOT_DIR/releases"
STACK_ZIP="$BUILD_DIR/service-connector.zip"
STACK_B64="$BUILD_DIR/service-connector.base64"

if [[ ! -d $BUILD_DIR ]]; then mkdir $BUILD_DIR && log "Created: $BUILD_DIR"; fi
if [[ -f $STACK_ZIP ]]; then rm $STACK_ZIP && log "Deleted Old: $STACK_ZIP"; fi
if [[ -f $STACK_B64 ]]; then rm $STACK_B64 && log "Deleted Old: $STACK_B64"; fi

cd $STACK_DIR

zip $STACK_ZIP \
    filter-logs.py \
    main.tf \
    provider.tf \
    outputs.tf \
    inputs.tf \
    debug.tf #>> /dev/null

# echo $?

if [ $? -eq 0 ]; then 
    log "Created New: $STACK_ZIP"
fi

base64 -i $STACK_ZIP -o "$STACK_B64" && log "Created New: $STACK_B64"

log "Build Success.\n"
# cat "$STACK_B64"