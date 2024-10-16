# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "local_file" "oke_cluster_entity" {
  count    = !local.create_new_k8s_entity && var.debug ? 1 : 0
  content  = jsonencode(data.oci_log_analytics_log_analytics_entity.oke_cluster_entity[0])
  filename = "${path.module}/tf-debug/oke_cluster_entity.json"
}

resource "local_file" "logan_namespaces" {
  count    = var.debug ? 1 : 0
  content  = jsonencode(data.oci_log_analytics_namespaces.logan_namespaces)
  filename = "${path.module}/tf-debug/logan_namespaces.json"
}

# Following resource to be used for dev validations

# data "oci_log_analytics_log_analytics_entity" "stack_created_entity" {
#   count                   = var.debug && local.create_new_k8s_entity ? 1 : 0
#   log_analytics_entity_id = oci_log_analytics_log_analytics_entity.oke_entity[0].id
#   namespace               = local.oci_la_namespace
# }

# resource "local_file" "stack_created_entity" {
#   count    = var.debug && local.create_new_k8s_entity ? 1 : 0
#   content  = jsonencode(data.oci_log_analytics_log_analytics_entity.stack_created_entity)
#   filename = "${path.module}/tf-debug/stack_created_entity.json"
# }