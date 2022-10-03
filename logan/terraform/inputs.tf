# When defined in the Terraform configuration, 
# the following variables automatically prepopulate with values on the Console pages used to create and edit the stack. 
# The stack's values are used when you select the Terraform actions Plan, Apply, and Destroy.
# - tenancy_ocid (tenancy OCID)
# - compartment_ocid (compartment OCID)
# - region (region)
# - current_user_ocid (OCID of the current user)
#
# Ref - https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager_topic-schema.htm#console-howto__prepop


variable "tenancy_ocid" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "region" {
  type = string
}

variable "current_user_ocid" {
  type = string
}

####
##  Inputs for HelmChart deployment in OKE Cluster Deployment
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

# OKE Container Image URL
variable "oke_containerImage_url" {
  type = string
}

# OKE Namespace
variable "oke_namespace" {
  type = string
}

# fluentd base direcotry path
variable "fluentd_baseDir_path" {
  type = string
}

# Logging Analytics namespace
variable "la_namespace" {
  type = string
}

# Logging Analytics LogGroupID
variable "la_logGroup_id" {
  type = string
}