# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
## Variable Group in schema.yaml: 
## RM stack auto populated inputs (hidden)
####

# Stack compartment - where marketplace app / Resoruce Manager stack is executed
variable "compartment_ocid" {
  type    = string
  default = ""
}

# OCID of user running the marketplace app / Resoruce Manager stack
variable "current_user_ocid" {
  type    = string
  default = ""
}

####
## Variable Group in schema.yaml: 
## Non-interactive stack inputs (hidden)
####

# Kubernetes Namespace
variable "kubernetes_namespace" {
  type    = string
  default = "oci-onm"
}

# livelab_switch inputs is defined in livelab_switch.tf

# OKE Cluster Name
variable "oke_cluster_name" {
  type    = string
  default = "DEFAULT"
}

# OKE Cluster Entity OCID
variable "oke_cluster_entity_ocid" {
  type    = string
  default = "DEFAULT"
}

####
## Variable Group in schema.yaml: 
## Select an OKE cluster deployed in this region to start monitoring
####

# OKE Cluster Compartment
variable "oke_compartment_ocid" {
  type = string
}

# OKE Cluster OCID
variable "oke_cluster_ocid" {
  type = string
}

####
## Variable Group in schema.yaml: 
## Select an OKE cluster deployed in this region to start monitoring
####

# Compartment for creating OCI Observability and Management resources
variable "oci_onm_compartment_ocid" {
  type    = string
  default = ""
}

# Option to create Logging Analytics
variable "opt_create_new_la_logGroup" {
  type    = bool
  default = false
}

# OCI Logging Analytics LogGroup OCID
variable "oci_la_logGroup_id" {
  type    = string
  default = ""
}

# New Log Group to collect Kubernetes data
variable "oci_la_logGroup_name" {
  type    = string
  default = ""
}

# Note:
# - This input is not used by chart but still defined to support user choice caching in RM stack
# - When user edits and existing RM stack - they will be able to view previously selected options
# - If this is not defined as terraform variable but just as schema.yaml input (to hide/show other UI elements)
# - Then this option will be reset to it's default value everytime user vists edit stack page
# - Therefore hiding previously selected advanced options from user
variable "opt_show_advanced_options" {
  type    = bool
  default = false
}

####
## Variable Group in schema.yaml: 
## Advanced Options: Helmchart
####

# Stack Deployment Options
variable "stack_deployment_option" {
  type    = string
  default = "Full"
}

# Option to deploy metric server
variable "opt_deploy_metric_server" {
  type    = bool
  default = true
}

# Option to use latest helmchart
variable "opt_use_latest_helmchart" {
  type    = bool
  default = true
}

# Option to use latest helmchart
variable "helmchart_version" {
  type    = string
  default = ""
}

# Fluentd Base Directory
variable "fluentd_baseDir_path" {
  type    = string
  default = "/var/log"
}

####
## Variable Group in schema.yaml: 
## Advanced Options: OCI
####

# Option to create Dynamic Group and Policies
variable "opt_create_dynamicGroup_and_policies" {
  type    = bool
  default = false
}

# Option to import dashboards
variable "opt_import_dashboards" {
  type    = bool
  default = true
}