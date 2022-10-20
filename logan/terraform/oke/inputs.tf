# When defined in the Terraform configuration, the following variables automatically prepopulate with values on the Console pages used to create and edit the stack. 
# The stack's values are used when you select the Terraform actions Plan, Apply, and Destroy.
# - tenancy_ocid (tenancy OCID)
# - region (region)
#
# Ref - https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager_topic-schema.htm#console-howto__prepop

####
##  Defualt inputs
####

variable "tenancy_ocid" {
  type = string
}

variable "region" {
  type = string
}

####
## Switches
####

variable "enable_local_testing" {
  type    = bool
  default = true
}

variable "enable_helm_release" {
  type    = bool
  default = true
}

variable "enable_dashboard_import" {
  type    = bool
  default = true
}

variable "enable_la_resources" {
  type    = bool
  default = true
}

####
##  Dynamic Group and Policies
####

# Option to create Dynamic Group and Policies
variable "opt_create_dynamicGroup_and_policies" {
  type    = bool
  default = true
}

####
##  OKE Cluster Information
####

# OKE Cluster Compartment
variable "oke_cluster_compartment" {
  type = string
}

# OKE Cluster OCID
variable "oke_cluster_ocid" {
  type = string
}

# OCI LA Fluentd Container Image
variable "container_image_url" {
  type = string
}

# Kubernetes Namespace
variable "kubernetes_namespace" {
  type = string
}

# Option to create Kubernetes Namespace
variable "opt_create_kubernetes_namespace" {
  type = bool
}

####
##  OCI Logging Analytics Information
####

# Compartment for creating dashboards and saved-searches
variable "oci_la_compartment_ocid" {
  type = string
}

# Option to create Logging Analytics
variable "opt_use_existing_la_logGroup" {
  type = bool
}

# OCI Logging Analytics LogGroup OCID
variable "oci_la_logGroup_id" {
  type    = string
  default = ""
}

# New Log Group to collect Kubernetes data
variable "oci_la_logGroup_name" {
  default = ""
  type    = string
}

####
##  Fluentd Configuration
####

# Fluentd Base Directory
variable "fluentd_baseDir_path" {
  type = string
}