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
tenancy_ocid     = "" 
region           = ""

# Note - Leave following empty when running terraform from OCI cloud-shell

# OCI user OCID
user_ocid        = ""
# Path to OCI user's API key
private_key_path = ""
# Fingerprint of the API key
fingerprint      = ""

####
##  Mandatory Stack inputs
####

# OKE Cluster Compartment OCID
oke_compartment_ocid = "" # Mandatory

# OKE Cluster OCID
oke_cluster_ocid = ""

# Change this, if you want to deploy in a custom namespace
kubernetes_namespace = "oci-onm"

# Compartment for creating dashboards and saved-searches  and logGroup
oci_la_compartment_ocid = ""

# if ture, oci_la_logGroup_name must be set
opt_create_new_la_logGroup = false 

# OCI Logging Analytics LogGroup
# Add OCID of logGroup if opt_use_existing_la_logGroup=true, leave it empty otherwise
oci_la_logGroup_id = "" 

# leave it unchanged, if opt_use_existing_la_logGroup=false
oci_la_logGroup_name = "NewLogGroupName" 

#### 
## Optional  Stack inputs
####

# Option to create Dynamic Group and Policies
opt_create_dynamicGroup_and_policies = true

# Fluentd installation path
fluentd_baseDir_path = "/var/log"

#### 
## Optional Switches
####

enable_dashboard_import = false
enable_helm_release     = false
enable_helm_debugging   = false
enable_macs             = false



