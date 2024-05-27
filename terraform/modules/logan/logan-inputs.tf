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

# New Entity name
variable "new_oke_entity_name" {
  type = string
}

# OKE Cluster Entity OCID
variable "entity_ocid" {
  type = string
}

# OCI Logging Analytics LogGroup OCID provided by user
variable "logGroup_ocid" {
  type = string
}

###############################

variable "debug" {
  type    = bool
  default = false
}

variable "tags" {
  type    = object({ freeformTags = map(string), definedTags = map(string) })
  default = { "freeformTags" = {}, "definedTags" = {} }
}

# # Option to create Logging Analytics
# variable "create_new_logGroup" { # opt_create_new_logGroup
#   type    = bool
#   default = false

#   validation {
#     condition     = var.create_new_logGroup && !null(var.new_logGroup_name)
#     error_message = "value"
#   }
# }

# variable "create_oke_entity" {
#   type    = bool
#   default = false

#   validation {
#     condition     = var.create_oke_entity && !null(var.new_oke_entity_name)
#     error_message = "value"
#   }
# }
