# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_log_analytics_namespaces" "logan_namespaces" {
  compartment_id = var.tenancy_ocid
}

locals {
  oci_la_namespace         = data.oci_log_analytics_namespaces.logan_namespaces.namespace_collection[0].items[0].namespace
  final_oci_la_logGroup_id = var.create_new_logGroup ? oci_log_analytics_log_analytics_log_group.new_log_group[0].id : var.existing_logGroup_id
  cluster_entity_properties = {
    topology_solution_k8s_onm_compartment_ocid  = var.compartment_ocid
    topology_solution_k8s_onm_metrics_namespace = "mgmtagent_kubernetes_metrics"
    topology_solution_k8s_trigger               = var.triggered_by_add_data_flow ? "add_data_flow" : null
  }
}

resource "oci_log_analytics_log_analytics_log_group" "new_log_group" {
  compartment_id = var.compartment_ocid
  display_name   = var.new_logGroup_name
  namespace      = local.oci_la_namespace
  description    = "LogGroup for Kubernetes Logs"

  count = var.create_new_logGroup ? 1 : 0

  # Preconditions are supported in terraform v 1.2.0+
  # Resource Manager supports 1.1.x as of Oct 18th, 2022
  #

  # lifecycle {
  #     precondition {
  #         condition     = data.oci_log_analytics_namespaces.logan_namespaces.namespace_collection[0].items[0].is_onboarded == true
  #         error_message = "Tenancy is not on-boarded to OCI Logging Analytics Service in ${var.region} region."
  #     }
  # }
}

resource "oci_log_analytics_log_analytics_entity" "oke_cluster" {
  compartment_id   = var.compartment_ocid
  entity_type_name = "Kubernetes Cluster"
  name             = var.kubernetes_cluster_name
  namespace        = local.oci_la_namespace
  properties       = local.cluster_entity_properties
}