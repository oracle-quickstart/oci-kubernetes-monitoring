# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
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

# Option to create Log Analytics
variable "opt_create_new_la_log_group" {
  type = bool
}

# OCI Log Analytics Log Group name (user input)
variable "log_group_display_name" {
  type = string
}

# OCI Log Analytics LogGroup OCID (user input)
variable "log_group_ocid" {
  type = string
}

# OKE Cluster Entity OCID
variable "oke_entity_ocid" {
  type = string
}

# OKE Entity metadata
variable "entity_metadata_list" {
  type = list(object({ name = string, type = string, value = string }))
}

# OKE Entity name
variable "new_entity_name" {
  type    = string
  default = null
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