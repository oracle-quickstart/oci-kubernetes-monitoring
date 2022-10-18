#!/bin/bash

OKE_CLUSTER_ID=$1

output=$(oci ce cluster get --cluster-id="${OKE_CLUSTER_ID}")

if [[ $? -ne 0 ]]; then
    # OCI Cluster Command Failed
    exit 1
fi

echo $output > okeClusterName.json

exit 0