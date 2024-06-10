# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
##  Provider Variables
####

variable "tenancy_ocid" {
  type = string
}

variable "region" {
  type = string
}

variable "user_ocid" {
  type    = string
  default = ""
}

variable "private_key_path" {
  type    = string
  default = ""
}

variable "fingerprint" {
  type    = string
  default = ""
}

####
## Boat configuration - Used for internal developement purpose only.
####

# Option to enable BOAT authentication.
variable "boat_auth" {
  type    = bool
  default = false
}

# OCID of BOAT tenancy.
variable "boat_tenancy_ocid" {
  type    = string
  default = ""
}

####
##  Shared Inputs
####

# Compartment for creating OCI Observability and Management resources
variable "oci_onm_compartment_ocid" {
  type = string
}

# OKE Cluster Compartment
variable "oke_compartment_ocid" {
  type = string
}

# OKE Cluster OCID
variable "oke_cluster_ocid" {
  type = string
}

# OCI Tags
variable "tags" {
  type    = object({ freeformTags = map(string), definedTags = map(string) })
  default = { "freeformTags" = {}, "definedTags" = {} }
}

####
##  IAM Module Inputs
####

# Option to create Dynamic Group and Policies
variable "opt_create_dynamicGroup_and_policies" {
  type    = bool
  default = false
}

####
##  Dashboards Module Inputs
####

# Option to import dashboards
variable "opt_import_dashboards" {
  type    = bool
  default = true
}

####
##  Logan Module
####

# New Log Group to collect Kubernetes data
variable "new_logGroup_name" {
  type = string
}

####
##  Helm Module
####

# Option to install helm chart
variable "install_helm_chart" {
  type = bool
}

# Option to use latest helmchart
variable "helmchart_version" {
  type = string
}

# Kubernetes Namespace
variable "kubernetes_namespace" {
  type    = string
  default = "oci-onm"
}

# Kubernetes Cluster OCID
variable "kubernetes_cluster_id" {
  type = string
}

# Kubernetes Cluster Name
variable "kubernetes_cluster_name" {
  type = string
}

# Local Path to oci-onm helm chart
variable "path_to_local_onm_helm_chart" {
  type = string
}

# Option to deploy metric server
variable "opt_deploy_metric_server" {
  type = bool
}

# Fluentd Base Directory
variable "fluentd_baseDir_path" {
  type    = string
  default = "/var/log"
}

# OKE Cluster Entity OCID
variable "user_provided_oke_cluster_entity_ocid" {
  type = string
}

# OCI Logging Analytics LogGroup OCID provided by user
variable "user_provided_oci_la_logGroup_ocid" {
  type = string
}

####
##  Developer Options
####

# Save data resources in local_file for debug purposes
variable "debug" {
  type    = bool
  default = false
}