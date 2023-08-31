# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  output_helm_external_values = yamlencode({
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
  })

  output_helm_command_2 = join(" ", [
    "helm install oci-kubernetes-monitoring oci-onm/oci-onm",
    "--set global.kubernetesClusterID=${var.oke_cluster_ocid}",
    "--set global.kubernetesClusterName=${local.oke_cluster_name}",
    "--set oci-onm-logan.ociLALogGroupID=${module.loggingAnalytics[0].oci_la_logGroup_ocid}",
    "--set oci-onm-logan.ociLANamespace=${module.loggingAnalytics[0].oci_la_namespace}",
    "--set oci-onm-mgmt-agent.mgmtagent.installKeyFileContent=${module.management_agent[0].mgmt_agent_install_key_content}"
  ])
}

output "helm_command_1" {
  value = "helm repo add oci-onm https://oracle-quickstart.github.io/oci-kubernetes-monitoring"
}

output "helm_command_2" {
  value = local.output_helm_command_2
}

output "oke_cluster_name" {
  value = local.oke_cluster_name
}

output "oci_la_namespace" {
  value = module.loggingAnalytics[0].oci_la_namespace
}

output "oci_la_logGroup_ocid" {
  value = module.loggingAnalytics[0].oci_la_logGroup_ocid
}

output "mgmt_agent_install_key_content" {
  value = module.management_agent[0].mgmt_agent_install_key_content
}

/* output "helm_external_values" {
  value = local.deploy_helm_ui_option ? null : local.output_helm_external_values
} */