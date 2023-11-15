# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # generate_helm_output evaluates to true in production
  generate_helm_output = alltrue([local.module_controls_enable_mgmt_agent_module, local.module_controls_enable_logan_module])

  output_helm_external_values = local.generate_helm_output ? yamlencode({
    "global" = {
      "kubernetesClusterID"   = var.oke_cluster_ocid
      "kubernetesClusterName" = local.oke_cluster_name
    }
    "oci-onm-logan" = {
      "ociLANamespace"       = module.loggingAnalytics[0].oci_la_namespace
      "ociLALogGroupID"      = module.loggingAnalytics[0].oci_la_logGroup_ocid
      "ociLAClusterEntityID" = var.oke_cluster_entity_ocid == "DEFAULT" ? null : var.oke_cluster_entity_ocid
    }
    "oci-onm-mgmt-agent" = {
      "mgmtagent" = {
        "installKeyFileContent" = module.management_agent[0].mgmt_agent_install_key_content
      }
    }
  }) : null


  cmd_1_helm_repo_add = "helm repo add oci-onm https://oracle-quickstart.github.io/oci-kubernetes-monitoring"

  cmd_2_helm_repo_update = "helm repo update"

  helm_install_opt_entity_id = var.oke_cluster_entity_ocid == "DEFAULT" ? "" : "--set oci-onm-logan.ociLAClusterEntityID=${var.oke_cluster_entity_ocid}"

  cmd_3_helm_install = local.generate_helm_output ? join(" ", [
    "helm install oci-kubernetes-monitoring oci-onm/oci-onm",
    "--set global.kubernetesClusterID=${var.oke_cluster_ocid}",
    "--set global.kubernetesClusterName=${local.oke_cluster_name}",
    "--set oci-onm-logan.ociLALogGroupID=${module.loggingAnalytics[0].oci_la_logGroup_ocid}",
    "--set oci-onm-logan.ociLANamespace=${module.loggingAnalytics[0].oci_la_namespace}",
    local.helm_install_opt_entity_id,
    "--set oci-onm-mgmt-agent.mgmtagent.installKeyFileContent=${module.management_agent[0].mgmt_agent_install_key_content}"
  ]) : null
}

###
# helm outputs
###

output "cmd_1_helm_repo_add" {
  value = local.generate_helm_output ? local.cmd_1_helm_repo_add : null
}

output "cmd_2_helm_repo_update" {
  value = local.generate_helm_output ? local.cmd_2_helm_repo_update : null
}

output "cmd_3_helm_install" {
  value = local.generate_helm_output ? local.cmd_3_helm_install : null
}

/* output "external_values_yaml" {
  value = local.output_helm_external_values
} */

###
# Module outputs
###

output "oke_cluster_name" {
  value = local.oke_cluster_name
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
  value = local.module_controls_enable_helm_module && var.dev_switch_generate_helm_template ? module.helm_release[0].helm_template : null
}