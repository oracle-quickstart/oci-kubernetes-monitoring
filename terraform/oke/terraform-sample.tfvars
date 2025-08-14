# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

################################################################################
#   About Comments:
#        Comments that starts with "//" are instruction
#        Comments that start with "#" are alternate input options
#
################################################################################

// Mandatory OCI provider inputs
tenancy_ocid = "<Enter Tenancy OCID here>"
region       = "<Enter Region Name here: ex: us-phoenix-1>"

// Set following inputs when not using instance principal authentication
# user_ocid    =
# private_key_path = 
# fingerprint = 

oke_compartment_ocid = "<Enter OKE compartment OCID here>"
oke_cluster_ocid     = "<Enter OKE Cluster OCID here>"

dropdown_create_dynamic_group_and_policies = "Create required IAM resources as part of the stack"
# dropdown_create_dynamic_group_and_policies = "I have already created the required IAM resources"

// This is the compartment in which dashboards, log group, entity, Management Agent key, metric namespace, and other related OCI resources are created.
// For the full list of resources, see https://github.com/oracle-quickstart/oci-kubernetes-monitoring
oci_onm_compartment_ocid = "<Enter oci-onm compartment OCID here>"

opt_create_new_la_log_group = true
oci_la_log_group_name       = "" # Optional: A LogGroup with ClusterName_ClusterCreationTimeStamp is auto created when empty sting is passed
// Alternative option for LogGroup:
# opt_create_new_la_log_group = false
# oci_la_log_group_ocid = "<Enter existing LogGroup OCID here>"

opt_create_oci_la_entity = true
// Alternative option for Entity:
# opt_create_oci_la_entity = false
# oke_cluster_entity_ocid = "<Enter a valid Log Analytics entity OCID of the type Kubernetes Cluster.>"

// If you opt to import dashboards:
// Ensure to manually delete the dashboards when you destroy the resources since the dashboards are not deleted automatically.

opt_import_dashboards = false
# opt_import_dashboards = true

// Select "Only OCI Resources" to skip helm chart installation on to your OKE cluster.
// Manually install the helm chart using the helm commands provided in the stack output.

stack_deployment_option = "Full"
# stack_deployment_option = "Only OCI Resources"

// Example, 3.3.0. For the list of releases, see https://github.com/oracle-quickstart/oci-kubernetes-monitoring/releases
// If not provided, then the latest oci-onm helm chart version is deployed. 
// However, if you need to upgrade to a newer version, then you must provide a version number here.

helm_chart_version = ""

opt_deploy_metric_server = true
# opt_deploy_metric_server = false

fluentd_base_dir_path = "/var/log"

// Optional tags input example
# tags = {
#   "freeformTags" = { "service" = "logan" },
#   "definedTags" = {
#     "Oracle-Recommended-Tags.ResourceOwner" = "John Doe",
#     "Oracle-Recommended-Tags.ResourceType"  = "O&M"
#   }
# }