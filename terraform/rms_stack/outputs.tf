# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

###
# Module outputs
###

output "cmd_1_helm_repo_add" {
  value = local.module_controls_enable_helm_module ? module.helm_release[0].cmd_1_helm_repo_add : null
}

output "cmd_2_helm_repo_update" {
  value = local.module_controls_enable_helm_module ? module.helm_release[0].cmd_2_helm_repo_update : null
}

output "cmd_3_helm_install" {
  value = local.module_controls_enable_helm_module ? module.helm_release[0].cmd_3_helm_install : null
}

output "oke_cluster_name" {
  value = module.oke.oke_cluster_name
}

output "oke_cluster_entity_ocid" {
  value = var.oke_cluster_entity_ocid == "DEFAULT" ? null : var.oke_cluster_entity_ocid
}

output "oke_dynamic_group_ocid" {
  value = local.module_controls_enable_iam_module ? module.policy_and_dynamic-group[0].oke_dynamic_group_ocid : null
}

output "oke_monitoring_policy_ocid" {
  value = local.module_controls_enable_iam_module ? module.policy_and_dynamic-group[0].oke_monitoring_policy_ocid : null
}

output "oci_la_namespace" {
  value = local.module_controls_enable_logan_module ? module.loggingAnalytics[0].oci_la_namespace : null
}

output "oci_la_logGroup_ocid" {
  value = local.module_controls_enable_logan_module ? module.loggingAnalytics[0].oci_la_logGroup_ocid : null
}

output "mgmt_agent_install_key" {
  value = local.module_controls_enable_mgmt_agent_module ? module.management_agent[0].mgmt_agent_install_key_content : null
}

output "helm_template" {
  value = local.module_controls_enable_helm_module && var.toggle_generate_helm_template ? module.helm_release[0].helm_template : null
}