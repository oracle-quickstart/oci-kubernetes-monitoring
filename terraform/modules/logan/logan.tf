# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  oci_la_namespace      = data.oci_log_analytics_namespaces.logan_namespaces.namespace_collection[0].items[0].namespace
  k8s_entity_type       = "Kubernetes Cluster"
  create_new_k8s_entity = var.oke_entity_ocid == null
}

data "oci_log_analytics_namespaces" "logan_namespaces" {
  compartment_id = var.tenancy_ocid

  lifecycle {
    # User Facing Error
    postcondition {
      condition     = !(self.namespace_collection == null)
      error_message = "Tenancy is not on-boarded to OCI Logging Analytics service."
    }
  }
}

data "oci_log_analytics_log_analytics_entity" "oke_cluster_entity" {
  count                   = !local.create_new_k8s_entity ? 1 : 0
  log_analytics_entity_id = var.oke_entity_ocid
  namespace               = local.oci_la_namespace

  lifecycle {
    # User Facing Error
    postcondition {
      # Incorrect Entity OCID check
      condition     = self.entity_type_name != null
      error_message = <<-EOT
        Invalid Entity OCID. Entity does not exist.
      EOT
    }

    # User Facing Error  
    postcondition {
      # Incorrect Entity Type check
      condition     = self.entity_type_name == local.k8s_entity_type
      error_message = <<-EOT
        Invalid Entity Type. Entity must be of type: Kubenetes Cluster.
      EOT
    }
  }
}

resource "oci_log_analytics_log_analytics_log_group" "new_log_group" {
  count = var.opt_create_new_la_log_group ? 1 : 0
  #Required
  compartment_id = var.compartment_ocid
  display_name   = var.log_group_display_name # display_name is updatable property
  namespace      = local.oci_la_namespace
  description    = "LogGroup for Kubernetes Logs"

  #tags
  defined_tags  = var.tags.definedTags
  freeform_tags = var.tags.freeformTags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_log_analytics_log_analytics_entity" "oke_entity" {
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
  # cloud_resource_id = null #TODO

  # Tags
  defined_tags  = var.tags.definedTags
  freeform_tags = var.tags.freeformTags

  lifecycle {
    ignore_changes = [name, metadata, defined_tags, freeform_tags, ]
    # Not a User Facing Error 
    precondition {
      condition     = !(var.new_entity_name == null && var.oke_entity_ocid == null)
      error_message = <<-EOT
        Cause : This is likely a logical error with the terraform module.
        Fix   : Report the issue at https://github.com/oracle-quickstart/oci-kubernetes-monitoring/issues
        Error : var.new_entity_name and var.oke_entity_ocid, both can not be null
      EOT
    }
  }
}