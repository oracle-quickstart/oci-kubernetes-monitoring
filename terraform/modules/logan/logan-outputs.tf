# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "oci_la_namespace" {
  value = local.oci_la_namespace
}

output "log_group_ocid" {
  value = !var.opt_create_new_la_log_group ? var.log_group_ocid : oci_log_analytics_log_analytics_log_group.new_log_group[0].id
}

output "oke_entity_ocid" {
  value = local.create_new_k8s_entity ? oci_log_analytics_log_analytics_entity.oke_entity[0].id : var.oke_entity_ocid
}