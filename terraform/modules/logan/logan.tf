# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  oci_la_namespace = data.oci_log_analytics_namespaces.logan_namespaces.namespace_collection[0].items[0].namespace
  k8s_entity_type  = "Kubernetes Cluster"

  create_new_logGroup   = var.logGroup_ocid == null
  create_new_k8s_entity = var.existing_entity_ocid == null
}

data "oci_log_analytics_namespaces" "logan_namespaces" {
  compartment_id = var.tenancy_ocid

  lifecycle {
    postcondition {
      condition     = !(self.namespace_collection == null)
      error_message = <<-EOT
        Logging Analytics On-board ERROR:
        Tenancy: ${var.tenancy_ocid} is not on-boarded to OCI Logging Analytics service.
        Please on-board to OCI Logging Analytics service from OCI console and retry.
      EOT
    }
  }
}

data "oci_log_analytics_log_analytics_entity" "user_provided_entity" {
  count                   = !local.create_new_k8s_entity ? 1 : 0
  log_analytics_entity_id = var.existing_entity_ocid
  namespace               = local.oci_la_namespace

  lifecycle {
    postcondition {
      # Incorrect Entity OCID check
      condition     = self.entity_type_name != null
      error_message = <<-EOT
        Incorrect entity OCID ERROR:
        Entity: ${var.existing_entity_ocid} is not a vaid Entity OCID
      EOT
    }
    postcondition {
      # Incorrect Entity Type check
      condition     = self.entity_type_name == local.k8s_entity_type
      error_message = <<-EOT
        Incorrect entity Type ERROR:
        Entity: ${var.existing_entity_ocid} is not of type: Kubenetes Cluster
      EOT
    }
  }
}

resource "oci_log_analytics_log_analytics_log_group" "new_log_group" {
  count = local.create_new_logGroup ? 1 : 0
  #Required
  compartment_id = var.compartment_ocid
  display_name   = var.new_logGroup_name
  namespace      = local.oci_la_namespace
  description    = "LogGroup for Kubernetes Logs"

  #tags
  defined_tags  = var.tags.definedTags
  freeform_tags = var.tags.freeformTags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_log_analytics_log_analytics_entity" "new_oke_entity" {
  count = local.create_new_k8s_entity ? 1 : 0
  #Required
  compartment_id   = var.compartment_ocid
  entity_type_name = local.k8s_entity_type
  name             = var.new_entity_name
  namespace        = local.oci_la_namespace

  metadata {
    dynamic "items" {
      for_each = [for x in var.entity_metadata_list : x]
      content {
        name  = items.value.name
        value = items.value.value
        type  = items.value.type
      }
    }
  }

  # Optional
  # cloud_resource_id = null #TODO Should we cluster OCID here ?

  # Tags
  defined_tags  = var.tags.definedTags
  freeform_tags = var.tags.freeformTags

  lifecycle {
    ignore_changes = [name, metadata, defined_tags, freeform_tags, ] #TODO should I keep metadata here
    precondition {
      condition     = !(var.new_entity_name == null && var.existing_entity_ocid == null)
      error_message = "Logical Error: var.new_entity_name and var.existing_entity_ocid, both can not be null"
    }
  }
}
