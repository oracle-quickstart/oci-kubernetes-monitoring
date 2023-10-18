# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
## Configure BOAT Authentication for OCI; Leave unchaged, if BOAT authentication is not used
####
boat_auth         = false
boat_tenancy_ocid = ""

####
##  OCI Provider inputs
####
tenancy_ocid = ""
region       = ""

# Note - Leave following empty when running terraform from OCI cloud-shell

# OCI user OCID
user_ocid = ""
# Path to OCI user's API key
private_key_path = ""
# Fingerprint of the API key
fingerprint = ""

####
##  Mandatory Stack inputs
####

# OKE Cluster Compartment OCID
oke_compartment_ocid = "" # Mandatory

# OKE Cluster OCID
oke_cluster_ocid = ""

# Change this, if you want to deploy in a custom namespace
kubernetes_namespace = "oci-onm"

# Option to control metric server installation as part of helm release
opt_deploy_metric_server = true

# Compartment for creating dashboards and saved-searches  and logGroup
oci_onm_compartment_ocid = ""

# if ture, oci_la_logGroup_name must be set
opt_create_new_la_logGroup = false

# OCI Logging Analytics LogGroup
# Add OCID of logGroup if opt_create_new_la_logGroup=false, leave it empty otherwise
oci_la_logGroup_id = ""

# leave it unchanged, if opt_create_new_la_logGroup=true
oci_la_logGroup_name = "NewLogGroupName"

#### 
## Optional  Stack inputs
####

# "Full" or "Only OCI Resources"
stack_deployment_option = "Only OCI Resources"

# Option to create Dynamic Group and Policies
opt_create_dynamicGroup_and_policies = true

# Fluentd installation path
fluentd_baseDir_path = "/var/log"


