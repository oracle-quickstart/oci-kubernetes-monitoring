locals {
  cmd_1_helm_repo_add    = "helm repo add oci-onm https://oracle-quickstart.github.io/oci-kubernetes-monitoring"
  cmd_2_helm_repo_update = "helm repo update"

  cmd_3_helm_install = join(" ", [
    "helm install oci-kubernetes-monitoring oci-onm/oci-onm",
    "--set global.namespace=${var.kubernetes_namespace}",
    "--set global.kubernetesClusterID=${var.kubernetes_cluster_id}",
    "--set global.kubernetesClusterName=${var.kubernetes_cluster_name}",
    "--set oci-onm-logan.ociLALogGroupID=${var.oci_la_logGroup_ocid}",
    "--set oci-onm-logan.ociLANamespace=${var.oci_la_namespace}",
    "--set oci-onm-logan.ociLAClusterEntityID=${var.oci_la_cluster_entity_ocid}",
    "--set oci-onm-mgmt-agent.deployMetricServer=${var.opt_deploy_metric_server}",
    "--set oci-onm-mgmt-agent.mgmtagent.installKeyFileContent=${var.mgmt_agent_install_key_content}"
  ])
}

# Helm release artifacts for local testing and validation.
output "helm_template" {
  value = var.generate_helm_template ? data.helm_template.oci-kubernetes-monitoring[0].manifest : null
}

output "cmd_1_helm_repo_add" {
  value = local.cmd_1_helm_repo_add
}

output "cmd_2_helm_repo_update" {
  value = local.cmd_2_helm_repo_update
}

output "cmd_3_helm_install" {
  value = local.cmd_3_helm_install
}