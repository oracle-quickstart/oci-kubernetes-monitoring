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
    echo -e "\t-d option passed - local helm-chart files will be part of stack zip"
else
    echo -e "\t-d option NOT passed - local helm-chart files will NOT be part of stack zip"
fi
if [ -n "$LIVE_LAB_BUILD" ]; then
    echo -e "\t-l option passed - livelab specific zip will be created"
fi

# Start
echo -e "\nBuilding -\n"

# Clean up stale temp build dirs and zip file
rm "$BUILD_ZIP" 2>/dev/null || :
rm -rf "$BUILD_DIR" 2>/dev/null || :

# Create a release DIR if it does not exist already.
if test ! -d "$RELEASE_PATH"; then
    mkdir "${RELEASE_PATH}" || error_and_exit "ERROR: mkdir ${RELEASE_PATH}"
    echo -e "Created release direcotory - \$PROJECT_HOME/releases"
fi

# Clean up old zip
rm "${RELEASE_ZIP}" 2>/dev/null && echo -e "Removed old stack - ${RELEASE_ZIP}"

# Switch to project's root for git archive
cd $ROOT_DIR || error_and_exit "ERROR: cd $ROOT_DIR"

# Create git archive as temp.zip
git archive HEAD -o "$BUILD_ZIP" --format=zip  >/dev/null || error_and_exit "ERROR: git archive HEAD -o $BUILD_ZIP --format=zip"
echo -e "Created git archive - $BUILD_ZIP"

# Unzip the temp.zip file
unzip -d "$BUILD_DIR" "$BUILD_ZIP" >/dev/null || error_and_exit "ERROR: unzip -d $BUILD_DIR $BUILD_ZIP"
echo -e "Unzipped git archive - $BUILD_DIR"
 
# Remove the helm-chart symlink
rm "$HELM_SYMLINK" || error_and_exit "ERROR: rm $HELM_SYMLINK"
echo -e "Removed helm-chart symlink - $HELM_SYMLINK"

if [ -n "$INCLUDE_LOCAL_HELM" ]; then
    # copy the helm-chart
    cp -R "$HELM_SOURCE" "$STACK_BUILD_PATH" || error_and_exit "ERROR: cp -R $HELM_SOURCE $STACK_BUILD_PATH"
    echo -e "Copied helm-chart at - $STACK_BUILD_PATH"
fi

# Remove the terraform modules symlink
rm "$MODULES_SYMLINK" || error_and_exit "ERROR: rm $MODULES_SYMLINK"
echo -e "Removed terraform modules symlink - $MODULES_SYMLINK"

# Copy the modules
cp -R "$MODULES_SOURCE" "$STACK_BUILD_PATH" || error_and_exit "ERROR: cp -R $MODULES_SOURCE $STACK_BUILD_PATH"
echo -e "Copied terraform modules at - $STACK_BUILD_PATH"

# Switch back to stack dir
cd "$STACK_BUILD_PATH" || error_and_exit "ERROR: cd $STACK_BUILD_PATH"

# Update livelab switch input to true
if [ -n "$LIVE_LAB_BUILD" ]; then
    sed "s/false/true/g" -i livelab_switch.tf  || error_and_exit "ERROR: sed \"s/false/true/g\" -i livelab_switch.tf"
    echo -e "Enabled livelab switch in $STACK_BUILD_PATH/livelab_switch.tf"
fi

# Create final stack zip
zip -r "${RELEASE_ZIP}" . >/dev/null  || error_and_exit "ERROR: zip -r ${RELEASE_ZIP} ."

# Display Output
echo -e "\nOutput -\n"
echo -e "Stack Created - ${RELEASE_ZIP}" 

# Switch back to util dir
cd "$RELEASE_PATH" || error_and_exit "ERROR: cd $RELEASE_PATH"

# Clean up stale dirs and files
rm "$BUILD_ZIP" 2>/dev/null || error_and_exit "ERROR: rm $BUILD_ZIP"
rm -rf "$BUILD_DIR" 2>/dev/null || error_and_exit "ERROR: rm -rf $BUILD_DIR"