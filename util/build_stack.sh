#!/bin/bash
# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Bash script to build OCI Resource Manager Stack or Marketplace app for OKE monitoring

# Fail at first error
set -e

SILENT_MODE=false
GENERATE_BASE64_ARTIFACT=false

function log {
    if [ "$SILENT_MODE" = false ]; then
        echo -e "$1"
    fi
}

# Helper Functions
function error_and_exit {
    log "$1"
    exit 1
}

function abspath    {
    relative_path=$1
    cd "$relative_path" || error_and_exit "Absolute path conversion failed: $relative_path"
    pwd
}

# define dir
UTIL_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
ROOT_DIR="$UTIL_DIR/.."
ROOT_DIR=$(abspath "$ROOT_DIR") # Convert to absolute path

RELEASE_PATH="$ROOT_DIR/releases"
UTIL_PATH="$ROOT_DIR/util"
BUILD_ZIP="${UTIL_PATH}/temp.zip"
BUILD_DIR="${UTIL_PATH}/temp"

HELM_SOURCE="$BUILD_DIR/charts"
MODULES_SOURCE="$BUILD_DIR/terraform/modules"

STACK_BUILD_PATH="$BUILD_DIR/terraform/oke"
HELM_SYMLINK="$STACK_BUILD_PATH/charts"
MODULES_SYMLINK="$STACK_BUILD_PATH/modules"

# Usage Instructions
usage="
$(basename "$0") [-h][-n name][-d][-s][-b] -- program to build OCI RMS stack zip file using oracle-quickstart/oci-kubernetes-monitoring repo.

where:
    -h  show this help text
    -n  name of output zip file without extention (Optional)
    -d  flag to generate dev build; contains local helm chart
    -s  flag to turn-off output; only final build file path is printed to stdout
    -b  flag to generate additional base64 string of stack

The zip artifacts shall be stored at -
    $RELEASE_PATH"

# Parse inputs
while getopts "hn:dsb" option; do
    case $option in
        h) # display Help
            echo "$usage"
            exit
            ;;
        n)  
            release_name=$OPTARG
            ;;
        d)
            INCLUDE_LOCAL_HELM=true
            ;;
        s) # Run SILENT_MODE
            SILENT_MODE=true
            ;;
        b) # Run SILENT_MODE
            GENERATE_BASE64_ARTIFACT=true
            ;;
        :) printf "missing argument for -%s\n" "$OPTARG" >&2
            echo "$usage" >&2
            exit 1
            ;;
        \?) printf "illegal option: -%s\n" "$OPTARG" >&2
            echo "$usage" >&2
            exit 1
            ;;
    esac
done

# Decide on final zip name
if test -z "${release_name}"; then
    PREFIX="oke";

    if [ -n "$INCLUDE_LOCAL_HELM" ]; then
        HELM_MODE="local-helm"
    else
        HELM_MODE="remote-helm"
    fi

    BRANCH=$(git symbolic-ref --short HEAD)
    COMMIT_HASH_SHORT=$(git rev-parse --short HEAD)
    COMMIT_COUNT=$(git rev-list --count HEAD)

    release_name="${PREFIX}-${HELM_MODE}-${BRANCH}-${COMMIT_HASH_SHORT}-${COMMIT_COUNT}"
fi

RELEASE_ZIP="${RELEASE_PATH}/${release_name}.zip"
BASE64_ARTIFACT="${RELEASE_PATH}/${release_name}.base64"

# Disclaimer
log "\nDisclaimers - \n"
if [ -n "$INCLUDE_LOCAL_HELM" ]; then
    log "\t-d option passed - local helm-chart files will be part of stack zip"
else
    log "\t-d option NOT passed - local helm-chart files will NOT be part of stack zip"
fi

# Start
log "\nBuilding -\n"

# Clean up stale temp build dirs and zip file
rm "$BUILD_ZIP" 2>/dev/null || :
rm -rf "$BUILD_DIR" 2>/dev/null || :

# Create a release DIR if it does not exist already.
if test ! -d "$RELEASE_PATH"; then
    mkdir "${RELEASE_PATH}" || error_and_exit "ERROR: mkdir ${RELEASE_PATH}"
    log "Created release direcotory - \$PROJECT_HOME/releases"
fi

# Clean up old artifacts
rm "${RELEASE_ZIP}" 2>/dev/null && log "Removed old zip artifact - ${RELEASE_ZIP}"
rm "${BASE64_ARTIFACT}" 2>/dev/null && log "Removed old base64 artifact - ${BASE64_ARTIFACT}"

# Switch to project's root for git archive
cd "$ROOT_DIR" || error_and_exit "ERROR: cd $ROOT_DIR"

# Create git archive as temp.zip
git archive HEAD -o "$BUILD_ZIP" --format=zip  >/dev/null || error_and_exit "ERROR: git archive HEAD -o $BUILD_ZIP --format=zip"
log "Created git archive - $BUILD_ZIP"

# Unzip the temp.zip file
unzip -d "$BUILD_DIR" "$BUILD_ZIP" >/dev/null || error_and_exit "ERROR: unzip -d $BUILD_DIR $BUILD_ZIP"
log "Unzipped git archive - $BUILD_DIR"

# Remove the helm-chart symlink
rm "$HELM_SYMLINK" || error_and_exit "ERROR: rm $HELM_SYMLINK"
log "Removed helm-chart symlink - $HELM_SYMLINK"

if [ -n "$INCLUDE_LOCAL_HELM" ]; then
    # copy the helm-chart
    cp -R "$HELM_SOURCE" "$STACK_BUILD_PATH" || error_and_exit "ERROR: cp -R $HELM_SOURCE $STACK_BUILD_PATH"
    log "Copied helm-chart at - $STACK_BUILD_PATH"
fi

# Remove the terraform modules symlink
rm "$MODULES_SYMLINK" || error_and_exit "ERROR: rm $MODULES_SYMLINK"
log "Removed terraform modules symlink - $MODULES_SYMLINK"

# Copy the modules
cp -R "$MODULES_SOURCE" "$STACK_BUILD_PATH" || error_and_exit "ERROR: cp -R $MODULES_SOURCE $STACK_BUILD_PATH"
log "Copied terraform modules at - $STACK_BUILD_PATH"

# Switch back to stack dir
cd "$STACK_BUILD_PATH" || error_and_exit "ERROR: cd $STACK_BUILD_PATH"

# Create final stack zip
zip -r "${RELEASE_ZIP}" . >/dev/null  || error_and_exit "ERROR: zip -r ${RELEASE_ZIP} ."

# Display Output
log "\nOutput -\n"
log "Stack Created - ${RELEASE_ZIP}" 

# Switch back to util dir
cd "$RELEASE_PATH" || error_and_exit "ERROR: cd $RELEASE_PATH"

# Clean up stale dirs and files
rm "$BUILD_ZIP" 2>/dev/null || error_and_exit "ERROR: rm $BUILD_ZIP"
rm -rf "$BUILD_DIR" 2>/dev/null || error_and_exit "ERROR: rm -rf $BUILD_DIR"

if [[ $GENERATE_BASE64_ARTIFACT = true ]]; then
    base64 -i "$RELEASE_ZIP" > "$BASE64_ARTIFACT"
    log "Base64 Artifact - $BASE64_ARTIFACT" # stdout
fi

if [[ $SILENT_MODE = true ]]; then
    echo "$RELEASE_ZIP" # stdout
fi

exit 0