# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "oci_la_namespace" {
  value = local.oci_la_namespace
}

output "oci_la_logGroup_ocid" {
  value = local.final_oci_la_logGroup_id
}

output "oke_cluster_entity_ocid" {
  value = var.create_oke_entity ? oci_log_analytics_log_analytics_entity.oke[0].id : null
}