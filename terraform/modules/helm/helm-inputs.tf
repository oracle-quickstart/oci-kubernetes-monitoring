# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
## Switches
####

variable "generate_helm_template" {
  type    = bool
  default = false
}

variable "install_helm_chart" {
  type    = bool
  default = true
}

variable "local_helm_chart" {
  type    = string
  default = null
}

####
##  Helm chart
####

# Option to use latest helm chart
variable "helm_chart_version" {
  type = string
}

####
##  Kubernetes Cluster Information
####

# Kubernetes Cluster OCID
variable "kubernetes_cluster_id" {
  type = string
}

# Kubernetes Cluster Name
variable "kubernetes_cluster_name" {
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
variable "oci_la_log_group_ocid" {
  type    = string
  default = ""
}

# OCI Log Analytics Namespace
variable "oci_la_namespace" {
  type = string
}

# OCI Logging Analytics Kubernetes Cluster Entity OCID
variable "oci_la_cluster_entity_ocid" {
  type = string
}

####
##  Fluentd Configuration
####

# Fluentd Base Directory
variable "fluentd_base_dir_path" {
  type    = string
  default = "/var/log"
}

####
##  Management Agent Configuration
####

# Management Agent Key
variable "mgmt_agent_install_key_content" {
  type = string
}

# Option to control the metric server deployment inside kubernetes cluster
variable "opt_deploy_metric_server" {
  type    = bool
  default = true
}

####
##  OCI Client Config
####

# OCI domain
variable "oci_domain" {
  type    = string
  default = null
}

####
##  Discovery Configuration
####

# Enable service logs collection for OKE infra components
variable "enable_service_log" {
  type    = bool
  default = false
}

# OCI Tags
variable "tags" {
  type    = object({ freeformTags = map(string), definedTags = map(string) })
  default = { "freeformTags" = {}, "definedTags" = {} }
}

####
##  Others
####

# Save data resources in local_file for debug purposes
variable "debug" {
  type    = bool
  default = false
}