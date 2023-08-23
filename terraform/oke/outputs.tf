# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  output_external_values_ymal = yamlencode({
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
}

output "helm_command_1" {
  value = "helm repo add oci-onm https://oracle-quickstart.github.io/oci-kubernetes-monitoring"
}

output "helm_command_2" {
  value = local.deploy_helm_ui_option ? null : local.output_external_values_ymal
}