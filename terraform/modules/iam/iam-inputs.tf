# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# tenancy ocid
variable "root_compartment_ocid" {
  type = string
}

# Compartment for OCI Observability and Management service resources
variable "oci_onm_compartment_ocid" {
  type = string
}

# OKE Cluster Compartment
variable "oke_compartment_ocid" {
  type = string
}

# OKE Cluster OCID
variable "oke_cluster_ocid" {
  type = string
}

# OCI Logging Analytics LogGroup OCID
variable "oci_la_log_group_ocid" {
  type = string
}

# Create policies for service logs discovery
variable "create_service_discovery_policies" {
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