# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
## Switches
####

variable "skip_helm_apply" {
  type    = bool
  default = false
}

####
##  Helm chart
####

variable "helm_abs_path" {
  type        = string
  description = "Absoulte path of helm chart"
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
  type = string
}

####
##  OCI Logging Analytics Information
####

# OCI Logging Analytics LogGroup OCID
variable "oci_la_logGroup_id" {
  type    = string
  default = ""
}

# Log Analytics Namespace
variable "oci_la_namespace" {
  type = string
}

####
##  Fluentd Configuration
####

# OCI LA Fluentd Container Image
variable "container_image_url" {
  type    = string
  default = "container-registry.oracle.com/oci_observability_management/oci-la-fluentd-collector:1.0.0"
}

# Fluentd Base Directory
variable "fluentd_baseDir_path" {
  type    = string
  default = "/var/log"
}

####
##  MACS Configuration
####

variable "installKeyFileContent" {
  type = string
}

# OCI Management Agent Container Image
variable "macs_agent_image_url" {
  type    = string
  default = "container-registry.oracle.com/oci_observability_management/oci-management-agent:1.0.0"
}

####
##  livelab
####

variable "deploy_mushop_config" {
  type    = bool
  default = false
}

variable "livelab_service_account" {
  type    = string
  default = ""
}