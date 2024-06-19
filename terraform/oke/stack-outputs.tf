# # Copyright (c) 2023, Oracle and/or its affiliates.
# # Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
## Stack outputs
####

output "cmd_1_helm_repo_add" {
  value = module.main.cmd_1_helm_repo_add
}

output "cmd_2_helm_repo_update" {
  value = module.main.cmd_2_helm_repo_update
}

output "cmd_3_helm_install" {
  value = module.main.cmd_3_helm_install
}

output "oke_cluster_entity_ocid" {
  value = module.main.oke_cluster_entity_ocid
}

output "oke_dynamic_group_ocid" {
  value = module.main.oke_dynamic_group_ocid
}

output "oke_monitoring_policy_ocid" {
  value = module.main.oke_monitoring_policy_ocid
}

output "oci_la_namespace" {
  value = module.main.oci_la_namespace
}

output "oci_la_logGroup_ocid" {
  value = module.main.oci_la_logGroup_ocid
}

output "mgmt_agent_install_key" {
  value = module.main.mgmt_agent_install_key
}