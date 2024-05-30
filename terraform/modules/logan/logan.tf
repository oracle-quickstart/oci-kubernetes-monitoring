# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  oci_la_namespace = data.oci_log_analytics_namespaces.logan_namespaces.namespace_collection[0].items[0].namespace
  k8s_entity_type  = "Kubernetes Cluster"

  create_new_logGroup   = var.logGroup_ocid == null #var.new_logGroup_name != null
  create_new_k8s_entity = var.entity_ocid == null   #var.new_oke_entity_name != null

  all_clusters_in_compartment = data.oci_containerengine_clusters.oke_clusters.clusters
  cluster_data                = [for c in local.all_clusters_in_compartment : c if c.id == var.oke_cluster_ocid][0]

  # OCI LA Kubernetes Cluster Entity Name
  oke_metadata_time_created      = local.cluster_data.metadata[0].time_created                                      # "2021-05-21 16:20:30 +0000 UTC"
  oke_time_created_rfc3398       = replace(replace(local.oke_metadata_time_created, " +0000 UTC", "Z", ), " ", "T") #"2021-05-21T16:20:30Z"
  oke_metadata_is_private        = !local.cluster_data.endpoint_config[0].is_public_ip_enabled
  oke_name                       = local.cluster_data.name
  new_oci_la_cluster_entity_name = "${local.oke_name}_${local.oke_time_created_rfc3398}"
  k8s_version                    = local.cluster_data.kubernetes_version

  entity_metadata = [
    { name : "cluster", value : local.new_oci_la_cluster_entity_name, type : "k8s_solution" },
    { name : "cluster_name", value : local.oke_name, type : "k8s_solution" },
    { name : "cluster_date", value : local.oke_time_created_rfc3398, type : "k8s_solution" },
    { name : "cluster_ocid", value : var.oke_cluster_ocid, type : "k8s_solution" },
    { name : "solution_type", value : "OKE", type : "k8s_solution" },
    { name : "k8s_version", value : local.k8s_version, type : "k8s_solution" },
    { name : "deployment_status", value : "ManualStackDeployment", type : "k8s_solution" },
    { name : "metrics_namespace", value : "mgmtagent_kubernetes_metrics", type : "k8s_solution" },
    { name : "onm_compartment", value : var.compartment_ocid, type : "k8s_solution" },
    { name : "deployment_stack_ocid", value : "ManualStackDeployment", type : "k8s_solution" }
  ]
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
  log_analytics_entity_id = var.entity_ocid
  namespace               = local.oci_la_namespace

  lifecycle {
    postcondition {
      # Incorrect Entity Type check
      condition     = self.entity_type_name == local.k8s_entity_type
      error_message = <<-EOT
        Incorrect entity Type ERROR:
        Entity: ${var.entity_ocid} is not of type: Kubenetes Cluster
      EOT
    }
  }
}

data "oci_containerengine_clusters" "oke_clusters" {
  compartment_id = var.oke_compartment_ocid
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

  #Optional
  # lifecycle {
  #   precondition {
  #     condition     = data.oci_log_analytics_namespaces.logan_namespaces.namespace_collection[0].items[0].is_onboarded == true
  #     error_message = "Tenancy is not on-boarded to OCI Logging Analytics Service in ${var.region} region."
  #   }
  # }
}

resource "oci_log_analytics_log_analytics_entity" "new_oke_entity" {
  count = local.create_new_k8s_entity ? 1 : 0
  #Required
  compartment_id   = var.compartment_ocid
  entity_type_name = local.k8s_entity_type
  name             = local.new_oci_la_cluster_entity_name
  namespace        = local.oci_la_namespace

  metadata {
    dynamic "items" {
      for_each = [for x in local.entity_metadata : x]
      content {
        name  = items.value.name
        value = items.value.value
        type  = items.value.type
      }
    }
  }

  #Optional
  cloud_resource_id = null #TODO add ocid of OKE later ?
  #tags
  defined_tags  = var.tags.definedTags
  freeform_tags = var.tags.freeformTags

  lifecycle {
    ignore_changes = [name, defined_tags, freeform_tags, metadata] #TODO should I keep metadata here
  }
  #   precondition {
  #     condition     = !(var.entity_ocid == null && var.new_oke_entity_name == null)
  #     error_message = "Logical Error: var.new_oke_entity_name and var.entity_ocid, both can not be null."
  #   }
  #   ## name:
  #   ##    Default entity name is generated from default OKE cluster name at the time of stack execution.
  #   ##    When OKE cluster name is udpated via UI, we should need deleate &create a new entity
  # }

}
