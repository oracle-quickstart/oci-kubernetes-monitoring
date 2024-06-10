# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
##  Provider Variables
####

# Mandatory OCI provider inputs
tenancy_ocid =
region       =

# Note: Leave following empty when running terraform from OCI cloud-shell
user_ocid    =
private_key_path = 
fingerprint = 

## Configure BOAT Authentication for OCI; Leave unchaged, if BOAT authentication is not used
boat_auth         = false
boat_tenancy_ocid = ""

#### [Section]
##  Select an OKE cluster deployed in this region to start monitoring
####

oke_compartment_ocid =
oke_cluster_ocid =

#### [Section]
##  Create Dynamic Group and Policy (tenancy level admin access required)
####

## Options: 
#   "Create required IAM resources as part of the stack"
#   "I have already created the required IAM resources"
dropdown_create_dynamicGroup_and_policies = 

#### [Section]
##  OCI Observability and Management Services Configuration
####

oci_onm_compartment_ocid =
## Options: 
#   true
#   false
opt_create_new_la_logGroup = true
# Optional
oci_la_logGroup_id = ""
# Optional
oci_la_logGroup_name = ""
# Optional
opt_create_new_la_entity = ""
# Optional
oke_cluster_entity_ocid = ""
## Options: 
#   true
#   false
opt_import_dashboards = false

#### [Section]
##  Advanced Configuration
####

## Options: 
#   "Full"
#   "Only OCI Resources"
stack_deployment_option = "Full"
# Optional
helm_chart_version = ""
## Options: 
#   true
#   false
opt_deploy_metric_server = true
# Optional
fluentd_baseDir_path = "/var/log"