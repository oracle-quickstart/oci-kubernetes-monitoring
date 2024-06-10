# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "oci_la_namespace" {
  value = local.oci_la_namespace
}

output "logGroup_ocid" {
  value = local.create_new_logGroup ? oci_log_analytics_log_analytics_log_group.new_log_group[0].id : var.logGroup_ocid
}

output "oke_entity_ocid" {
  value = local.create_new_k8s_entity ? oci_log_analytics_log_analytics_entity.new_oke_entity[0].id : var.existing_entity_ocid
}