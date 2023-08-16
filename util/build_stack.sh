#!/bin/bash
# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Bash script to build OCI Resource Manager Stack or Marketplace app for OKE monitoring

# Fail at first error
set -e

function error_and_exit {
    echo -e "ERROR: $1"
    exit
}

function abspath    {
    relative_path=$1
    cd $relative_path
    pwd
}

usage="
$(basename "$0") [-h] [-n name] -- program to build marketplace app from oracle-quickstart/oci-kubernetes-monitoring repo.

where:
    -h  show this help text
    -n  name of output zip file without extention (Optional)
    -l  flag to generate livelab build; otherwise oke build is generated

The zip artifacts shall be stored at -
     $RELEASE_PATH"

while getopts "hn:l" option; do
    case $option in
        h) # display Help
            echo "$usage"
            exit
            ;;
        l) #livelab-build
            LIVE_LAB_BUILD=true
            ;;
        n)  
            release_name=$OPTARG
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

ROOT_DIR=".."
ROOT_DIR=$(abspath $ROOT_DIR) # Convert to absolute path

RELEASE_PATH="$ROOT_DIR/releases"
TEMP_ZIP="${RELEASE_PATH}/temp.zip"
TEMP_DIR="${RELEASE_PATH}/temp"

HELM_SOURCE="$ROOT_DIR/charts"
MODULES_SOURCE="$ROOT_DIR/terraform/modules"
ROOT_MODULE_PATH="$ROOT_DIR/terraform/oke"

if [ -n "$LIVE_LAB_BUILD" ]; then
    PREFIX="livelab"
else
    PREFIX="oke"
fi

# Create a release DIR if it does not exist already.
if test ! -d "$RELEASE_PATH"; then
    mkdir "${RELEASE_PATH}" || error_and_exit "Could not create releases DIR."
    echo -e "Create release DIR: ${RELEASE_PATH}"
fi

# Change to git repo
cd "$ROOT_DIR" || error_and_exit "Could not switch DIR"

# Decide on final zip name
if test -z "${release_name}"; then
    BRANCH=$(git symbolic-ref --short HEAD)
    COMMIT_HASH_SHORT=$(git rev-parse --short HEAD)
    COMMIT_COUNT=$(git rev-list --count HEAD)
    release_name="${PREFIX}-${BRANCH}-${COMMIT_HASH_SHORT}-${COMMIT_COUNT}"
fi

RELEASE_ZIP="${RELEASE_PATH}/${release_name}.zip"

echo -e ""
echo -e "Build parameters - "
echo -e ""
echo -e "ROOT_DIR = $ROOT_DIR"
echo -e "HELM_SOURCE = $HELM_SOURCE"
echo -e "MODULES_SOURCE = $MODULES_SOURCE"
echo -e "TEMP_DIR = $TEMP_DIR"
echo -e "TEMP_ZIP = $TEMP_ZIP"
echo -e "RELEASE_ZIP = $RELEASE_ZIP"
echo -e "ROOT_MODULE_PATH = $ROOT_MODULE_PATH"
echo -e ""

# Clean up stale dirs and files
rm "${RELEASE_ZIP}" 2>/dev/null && echo -e "Removed stale release zip"
rm "$TEMP_ZIP" 2>/dev/null && echo -e "Removed stale temp zip"
rm -rf "$TEMP_DIR" 2>/dev/null && echo -e "Removed stale temp dir"

# Switch to Root Module for gitzip
cd $ROOT_MODULE_PATH || echo -e "Failed to Switch to root module"

# Create git archive as temp.zip
git archive HEAD -o "$TEMP_ZIP" --format=zip  >/dev/null || error_and_exit "git archive failed."
echo -e "Created Git archive - temp.zip"

# Switch back to release dir
# cd "$RELEASE_PATH" || error_and_exit "Could not switch back to releases dir."
# echo -e "Switched back to releases DIR."

# unzip the temp.zip file
unzip -d "$TEMP_DIR" "$TEMP_ZIP" >/dev/null || error_and_exit "Could not unzip temp.zip"
echo -e "Unzipped temp.zip to temp dir"

# remove the helm-chart symlink
rm "$TEMP_DIR/charts" || error_and_exit "Could not remove helm-chart symlink"
echo -e "Removed helm-chart symlink"

# copy the helm-chart
cp -R "$HELM_SOURCE" "$TEMP_DIR" || error_and_exit "Could not copy helm chart"
echo -e "Copied helm-chart to temp dir"

# remove the terraform modules symlink
rm "$TEMP_DIR/modules" || error_and_exit "Could not remove modules symlink"
echo -e "Removed terraform modules symlink"

# copy the modules
cp -R "$MODULES_SOURCE" "$TEMP_DIR" || error_and_exit "Could not copy modules"
echo -e "Copied orignal modules"

# switch back to temp dir
cd "$TEMP_DIR" || error_and_exit "Could not switch to temp dir"
echo -e "Switched to temp dir"

# update livelab switch input to true
if [ -n "$LIVE_LAB_BUILD" ]; then
    sed "s/false/true/g" -i livelab-switch.tf
    echo -e "Enabled livelab switch in livelab-switch.tf"
fi

# create zip
zip -r "${RELEASE_ZIP}" ./* >/dev/null  || error_and_exit "Could not zip temp dir"

# switch back to util dir
cd "$RELEASE_PATH" || error_and_exit "Could not switch to Util dir"

# clean up temp zip file
rm "$TEMP_ZIP" 2>/dev/null && echo -e "stale zip file removed."
rm -rf "$TEMP_DIR" 2>/dev/null && echo -e "stale zip dir removed."

echo -e "\nNew Release Created - $RELEASE_PATH/$release_name.zip"



