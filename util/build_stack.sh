#!/bin/bash
# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Bash script to build OCI Resource Manager Stack or Marketplace app for OKE monitoring

# Fail at first error
set -e

# Helper Functions
function error_and_exit {
    echo -e "ERROR: $1"
    exit
}

function abspath    {
    relative_path=$1
    cd $relative_path
    pwd
}

ROOT_DIR=".."
ROOT_DIR=$(abspath $ROOT_DIR) # Convert to absolute path

RELEASE_PATH="$ROOT_DIR/releases"
TEMP_ZIP="${RELEASE_PATH}/temp.zip"
TEMP_DIR="${RELEASE_PATH}/temp"

HELM_SOURCE="$ROOT_DIR/charts"
MODULES_SOURCE="$ROOT_DIR/terraform/modules"
ROOT_MODULE_PATH="$ROOT_DIR/terraform/oke"

# Usage Instructions
usage="
$(basename "$0") [-h] [-n name] -- program to build marketplace app from oracle-quickstart/oci-kubernetes-monitoring repo.

where:
    -h  show this help text
    -n  name of output zip file without extention (Optional)
    -l  flag to generate livelab build; otherwise oke build is generated
    -d  flag to generate dev build; contains local helm chart

The zip artifacts shall be stored at -
     $RELEASE_PATH"


# Parse inputs
while getopts "hn:ld" option; do
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
        d)
            INCLUDE_LOCAL_HELM=true
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
    if [ -n "$LIVE_LAB_BUILD" ]; then
        PREFIX="livelab"; 
    else 
        PREFIX="oke"; 
    fi

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

# Disclaimer
echo -e "\nDisclaimers - \n"
if [ -n "$INCLUDE_LOCAL_HELM" ]; then
    echo -e "-d option passed - local helm-chart files will be part of stack zip"
else
    echo -e "-d option NOT passed - local helm-chart files will NOT be part of stack zip"
fi
if [ -n "$LIVE_LAB_BUILD" ]; then
    echo -e "-l option passed - livelab specific zip will be created"
fi

# Echo Build Parameters
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

# Start
echo -e "Building -\n"

# Create a release DIR if it does not exist already.
if test ! -d "$RELEASE_PATH"; then
    mkdir "${RELEASE_PATH}" || error_and_exit "Could not create releases DIR."
    echo -e "Created release DIR: ${RELEASE_PATH}"
fi

#clean up old zip
rm "${RELEASE_ZIP}" 2>/dev/null && echo -e "Removed stale release zip - ${RELEASE_ZIP}"

# Clean up stale dirs and files
rm "$TEMP_ZIP" 2>/dev/null && echo -e "Removed stale temp zip - $TEMP_ZIP"
rm -rf "$TEMP_DIR" 2>/dev/null && echo -e "Removed stale temp dir - $TEMP_DIR"

# Switch to Root Module for gitzip
cd $ROOT_MODULE_PATH || error_and_exit "Failed to Switch to root module"
echo -e "Switched to Root Module - $ROOT_MODULE_PATH"

# Create git archive as temp.zip
git archive HEAD -o "$TEMP_ZIP" --format=zip  >/dev/null || error_and_exit "git archive failed."
echo -e "Created Git archive - $TEMP_ZIP"

# unzip the temp.zip file
unzip -d "$TEMP_DIR" "$TEMP_ZIP" >/dev/null || error_and_exit "Could not unzip temp.zip"
echo -e "Unzipped temp.zip to $TEMP_DIR"

# remove the helm-chart symlink
rm "$TEMP_DIR/charts" || error_and_exit "Could not remove helm-chart symlink"
echo -e "Removed helm-chart symlink - $TEMP_DIR/charts"

if [ -n "$INCLUDE_LOCAL_HELM" ]; then
    # copy the helm-chart
    cp -R "$HELM_SOURCE" "$TEMP_DIR" || error_and_exit "Could not copy helm chart"
    echo -e "Copied helm-chart to $TEMP_DIR"
fi

# remove the terraform modules symlink
rm "$TEMP_DIR/modules" || error_and_exit "Could not remove modules symlink"
echo -e "Removed terraform modules symlink - $TEMP_DIR/modules"

# copy the modules
cp -R "$MODULES_SOURCE" "$TEMP_DIR" || error_and_exit "Could not copy modules"
echo -e "Copied orignal modules to $TEMP_DIR"

# switch back to temp dir
cd "$TEMP_DIR" || error_and_exit "Could not switch to temp dir"
echo -e "Switched to $TEMP_DIR"

# update livelab switch input to true
if [ -n "$LIVE_LAB_BUILD" ]; then
    sed "s/false/true/g" -i livelab_switch.tf
    echo -e "Enabled livelab switch in livelab_switch.tf"
fi

# create zip
zip -r "${RELEASE_ZIP}" ${TEMP_DIR}/* >/dev/null  || error_and_exit "Could not zip $TEMP_DIR"

# switch back to util dir
cd "$RELEASE_PATH" || error_and_exit "Could not switch to $RELEASE_PATH"

# Clean up stale dirs and files
rm "$TEMP_ZIP" 2>/dev/null && echo -e "Removed stale temp zip - $TEMP_ZIP"
rm -rf "$TEMP_DIR" 2>/dev/null && echo -e "Removed stale temp dir - $TEMP_DIR"

# Start
echo -e "\nOutput -\n"

echo -e "New Release Created - $RELEASE_PATH/$release_name.zip"



