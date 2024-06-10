# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# tenancy OCID
variable "tenancy_ocid" {
  type = string
}

# region
variable "region" {
  type = string
}

# Compartment for creating new logan resources
variable "compartment_ocid" {
  type = string
}

# New Log Group to collect Kubernetes data
variable "new_logGroup_name" {
  type = string
}

# OKE Cluster Entity OCID
variable "existing_entity_ocid" {
  type = string
}

variable "entity_metadata_list" {
  type = list(object({ name = string, type = string, value = string }))
}

variable "new_entity_name" {
  type    = string
  default = null
}

# OCI Logging Analytics LogGroup OCID provided by user
variable "logGroup_ocid" {
  type = string
}

# Save data resources in local_file for debug purposes
variable "debug" {
  type    = bool
  default = false
}

# OCI Tags
variable "tags" {
  type    = object({ freeformTags = map(string), definedTags = map(string) })
  default = { "freeformTags" = {}, "definedTags" = {} }
}