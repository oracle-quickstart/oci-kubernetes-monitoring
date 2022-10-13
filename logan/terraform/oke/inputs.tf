# When defined in the Terraform configuration, the following variables automatically prepopulate with values on the Console pages used to create and edit the stack. 
# The stack's values are used when you select the Terraform actions Plan, Apply, and Destroy.
# - tenancy_ocid (tenancy OCID)
# - region (region)
#
# Ref - https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager_topic-schema.htm#console-howto__prepop


variable "tenancy_ocid" {
  type = string
}

variable "region" {
  type = string
}

####
##  Inputs for deploying helm-chart
####

# OKE Cluster Compartment
variable "oke_cluster_compartment" {
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

# OCI LA Fluentd Container Image
variable "container_image_url" {
  type = string
}

# Kubernetes Namespace
variable "kubernetes_namespace" {
  type = string
}

# Fluentd Base Directory
variable "fluentd_baseDir_path" {
  type = string
}

# OCI Logging Analytics Namespace
variable "oci_la_namespace" {
  type = string
}

# OCI Logging Analytics LogGroup OCID
variable "oci_la_logGroup_id" {
  type = string
}

# Compartment for creating dashboards and saved-searches
variable oci_la_compartment_ocid {
  type = string
}