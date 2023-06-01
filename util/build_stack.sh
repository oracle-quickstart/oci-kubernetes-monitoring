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

ROOT_DIR=".."
ROOT_DIR=$(abspath $ROOT_DIR) # Convert to absolute path

RELEASE_PATH="$ROOT_DIR/releases"

usage="
$(basename "$0") [-h] [-n name] -- program to build marketplace app from oracle-quickstart/oci-kubernetes-monitoring repo.

where:
    -h  show this help text
    -n  name of output zip file without extention (Optional)

The zip artifacts shall be stored at -
     $RELEASE_PATH"

while getopts "hn:" option; do
    case $option in
        h) # display Help
            echo "$usage"
            exit
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
    release_name="${BRANCH}-${COMMIT_HASH_SHORT}-${COMMIT_COUNT}"
fi

RELEASE_ZIP="${RELEASE_PATH}/${release_name}.zip"

# Clean up an existing zip file, if exists
rm "${RELEASE_ZIP}" 2>/dev/null && echo -e "Removed stale zip." 

# Create git archive
git archive HEAD -o "$RELEASE_ZIP" --format=zip  >/dev/null || error_and_exit "git archive failed."
echo -e "Created release - $RELEASE_ZIP"
