# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# # RMS private endpoint OCID provided by user
variable "private_endpoint_ocid" {
  type = string
  # Not a User Facing Error
  validation {
    condition     = var.private_endpoint_ocid == null ? true : length(regexall("^ocid1\\.ormprivateendpoint\\S*$", var.private_endpoint_ocid)) > 0
    error_message = "Incorrect format: var.private_endpoint_ocid"
  }
}

# OCI Subnet OCID provided by user
variable "oke_subnet_ocid" {
  type = string
  # Not a User Facing Error
  validation {
    condition     = var.oke_subnet_ocid == null ? true : length(regexall("^ocid1\\.subnet\\S*$", var.oke_subnet_ocid)) > 0
    error_message = "Incorrect format: var.oke_subnet_ocid"
  }
}

# Compartment to host RMS private endpoint
variable "pe_compartmnet_ocid" {
  type = string
}

# OKE Cluster Private IP Address
variable "private_ip_address" {
  type     = string
  nullable = false
}

# OKE Cluster OCID
variable "oke_vcn_ocid" {
  type = string
}

# OCI Tags
variable "tags" {
  type    = object({ freeformTags = map(string), definedTags = map(string) })
  default = { "freeformTags" = {}, "definedTags" = {} }
}

# Save data resources in local_file for debug purposes
variable "debug" {
  type    = bool
  default = false
}