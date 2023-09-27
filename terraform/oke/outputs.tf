# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  can_generate_helm_output = alltrue([local.module_controls_enable_mgmt_agent_module, local.module_controls_enable_logan_module])

  output_helm_external_values = local.can_generate_helm_output ? yamlencode({
    "global" = {
      "kubernetesClusterID"   = var.oke_cluster_ocid
      "kubernetesClusterName" = local.oke_cluster_name
    }
    "oci-onm-logan" = {
      "ociLANamespace"  = module.loggingAnalytics[0].oci_la_namespace
      "ociLALogGroupID" = module.loggingAnalytics[0].oci_la_logGroup_ocid
    }
    "oci-onm-mgmt-agent" = {
      "mgmtagent" = {
        "installKeyFileContent" = module.management_agent[0].mgmt_agent_install_key_content
      }
    }
  }) : null


  helm_repo_add_cmd = "helm repo add oci-onm https://oracle-quickstart.github.io/oci-kubernetes-monitoring"

  helm_install_cmd = local.can_generate_helm_output ? join(" ", [
    "helm install oci-kubernetes-monitoring oci-onm/oci-onm",
    "--set global.kubernetesClusterID=${var.oke_cluster_ocid}",
    "--set global.kubernetesClusterName=${local.oke_cluster_name}",
    "--set oci-onm-logan.ociLALogGroupID=${module.loggingAnalytics[0].oci_la_logGroup_ocid}",
    "--set oci-onm-logan.ociLANamespace=${module.loggingAnalytics[0].oci_la_namespace}",
    "--set oci-onm-mgmt-agent.mgmtagent.installKeyFileContent=${module.management_agent[0].mgmt_agent_install_key_content}"
  ]) : null
}

###
# helm outputs
###

output "helm_repo_add_cmd" {
  value = local.can_generate_helm_output ? local.helm_repo_add_cmd : null
}

output "helm_install_cmd" {
  value = local.can_generate_helm_output ? local.helm_install_cmd : null
}

output "oke_cluster_name" {
  value = local.oke_cluster_name
}

###
# Module outputs
###

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

output "mgmt_agent_install_key_content" {
  value = local.module_controls_enable_mgmt_agent_module ? module.management_agent[0].mgmt_agent_install_key_content : null
}

output "helm_template" {
    value = local.module_controls_enable_helm_module && var.dev_switch_generate_helm_template ? module.helm_release[0].helm_template : null
}