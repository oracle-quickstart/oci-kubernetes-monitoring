# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
## Switches
####

variable "generate_helm_template" {
  type    = bool
  default = false
}

variable "install_helm" {
  type    = bool
  default = true
}

variable "use_local_helm_chart" {
  type    = bool
  default = false
}

####
##  Helm chart
####

# Option to use latest helmchart
variable "helmchart_version" {
  type    = string
  default = null
}

# Used for local testing
# Absoulte path to helm chart directory
variable "helm_abs_path" {
  type    = string
  default = "optional"
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

# OKE Cluster Name
variable "oke_cluster_name" {
  type = string
}

# OKE Cluster Entity OCID
variable "oke_cluster_entity_ocid" {
  type    = string
  default = "DEFAULT" # Keep default as DEFAULT
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

# Fluentd Base Directory
variable "fluentd_baseDir_path" {
  type    = string
  default = "/var/log"
}

####
##  Management Agent Configuration
####

variable "mgmt_agent_install_key_content" {
  type = string
}

# Option to control the metric server deployment inside kubernetes cluster
variable "opt_deploy_metric_server" {
  type    = bool
  default = true
}

####
##  livelab
####

# Option to deploy mushop specific values.yaml (inputs)
variable "deploy_mushop_config" {
  type    = bool
  default = false
}

# Service Account to be used when working on livelab cluster
variable "livelab_service_account" {
  type    = string
  default = ""
}

variable "debug" {
  type    = bool
  default = false
}