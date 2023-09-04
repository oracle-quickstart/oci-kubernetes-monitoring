# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# When defined in the Terraform configuration, the following variables automatically prepopulate with values on the Console pages used to create and edit the stack.
# The stack's values are used when you select the Terraform actions Plan, Apply, and Destroy.
# - tenancy_ocid (tenancy OCID)
# - region (region)
#
# Ref - https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager_topic-schema.htm#console-howto__prepop

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
## Stack Variable - Auto-pupulated while running RM Stack
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
##  Dynamic Group and Policies
####

# Option to create Dynamic Group and Policies
variable "opt_create_dynamicGroup_and_policies" {
  type    = bool
  default = false
}

####
##  OKE Cluster Information
####

# OKE Cluster Compartment
variable "oke_compartment_ocid" {
  type = string
}

# OKE Cluster OCID
variable "oke_cluster_ocid" {
  type = string
}

# Kubernetes Namespace
variable "kubernetes_namespace" {
  type    = string
  default = "oci-onm"
}

####
##  OCI Observability and Management Information
####

# Stack Deployment Options
variable "stack_deployment_option" {
  type    = string
  default = "Full"
}

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

# Fluentd Base Directory
variable "fluentd_baseDir_path" {
  type    = string
  default = "/var/log"
}

####
##  Fluentd Configuration
####

# OCI LA Fluentd Container Image
variable "logan_container_image_url" {
  type    = string
  default = "container-registry.oracle.com/oci_observability_management/oci-la-fluentd-collector:1.0.0"
}

####
##  Management Agent Configuration
####

# OCI Management Agent Container Image
variable "mgmt_agent_container_image_url" {
  type    = string
  default = "container-registry.oracle.com/oci_observability_management/oci-management-agent:1.0.0"
}

# Option to deploy metric server
variable "opt_deploy_metric_server" {
  type    = bool
  default = true
}

####
##  Input options hidden from stack UI
####

# add data flow identifier
variable "triggered_by_add_data_flow" {
  type    = bool
  default = false
}

# OKE Cluster Name
variable "oke_cluster_name" {
  type    = string
  default = "NoInput" # refactor, if need to change default input
}

# OKE Cluster Entity OCID
variable "oke_cluster_entity_ocid" {
  type    = string
  default = "NoInput" # refactor, if need to change default input
}