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
## Stack Variable
####

// Auto-pupulated while running RM Stack
variable "compartment_ocid" {
  type = string
  default = ""
}

####
## Boat configuration
####

variable "boat_auth" {
  type    = bool
  default = false
}

variable "boat_tenancy_ocid" {
  type    = string
  default = ""
}

####
## Switches
####

variable "enable_helm_release" {
  type    = bool
  default = true
}

variable "enable_helm_debugging" {
  type    = bool
  default = false
}

variable "enable_dashboard_import" {
  type    = bool
  default = true
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
  default = "place-holder"
}

# OKE Cluster OCID
variable "oke_cluster_ocid" {
  type = string
  default = "place-holder"
}

# Kubernetes Namespace
variable "kubernetes_namespace" {
  type = string
  default = "place-holder"
}

# Option to create Kubernetes Namespace
variable "opt_create_kubernetes_namespace" {
  type = bool
  default = true
}

####
##  OCI Logging Analytics Information
####

# Compartment for creating logging analytics LogGroup and Dashboards
variable "oci_la_compartment_ocid" {
  type = string
  default = "place-holder"
}

# Option to create Logging Analytics
variable "opt_create_new_la_logGroup" {
  type = bool
  default = false
}

# OCI Logging Analytics LogGroup OCID
variable "oci_la_logGroup_id" {
  type    = string
  default = "place-holder"
}

# New Log Group to collect Kubernetes data
variable "oci_la_logGroup_name" {
  default = ""
  type    = string
}

####
##  Fluentd Configuration
####

# OCI LA Fluentd Container Image
variable "container_image_url" {
  type = string
  default = "place-holder"
}

# Fluentd Base Directory
variable "fluentd_baseDir_path" {
  type = string
  default = "/var/log"
}