# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  remote_helm_repo = "https://oracle-quickstart.github.io/oci-kubernetes-monitoring"
  chart_name       = "oci-onm"

  is_local_helm_chart = var.local_helm_chart != null

  chart      = local.is_local_helm_chart ? var.local_helm_chart : local.chart_name
  repository = local.is_local_helm_chart ? null : local.remote_helm_repo
  version    = local.is_local_helm_chart ? null : var.helm_chart_version

  kubernetes_cluster_name = var.kubernetes_cluster_name

  helm_inputs = {
    # global
    "global.namespace"             = var.kubernetes_namespace
    "global.kubernetesClusterID"   = var.kubernetes_cluster_id
    "global.kubernetesClusterName" = local.kubernetes_cluster_name

    # oci-onm-logan
    "oci-onm-logan.ociLANamespace"       = var.oci_la_namespace
    "oci-onm-logan.ociLALogGroupID"      = var.oci_la_log_group_ocid
    "oci-onm-logan.fluentd.baseDir"      = var.fluentd_base_dir_path
    "oci-onm-logan.ociLAClusterEntityID" = var.oci_la_cluster_entity_ocid

    # oci-onm-mgmt-agent
    "oci-onm-mgmt-agent.mgmtagent.installKeyFileContent" = var.mgmt_agent_install_key_content
    "oci-onm-mgmt-agent.deployMetricServer"              = var.opt_deploy_metric_server
  }
}

# Create helm release
resource "helm_release" "oci-kubernetes-monitoring" {
  name              = "oci-kubernetes-monitoring"
  repository        = local.repository
  chart             = local.chart
  version           = local.version
  wait              = true
  dependency_update = true
  cleanup_on_fail   = true
  atomic            = true

  values = var.deploy_mushop_config ? ["${file("${path.module}/mushop_values.yaml")}"] : null

  dynamic "set" {
    for_each = local.helm_inputs
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.oci_domain == null ? {} : { "oci-onm-logan.ociDomain" = var.oci_domain }
    content {
      name  = set.key
      value = set.value
    }
  }

  count = var.install_helm_chart ? 1 : 0
}

# Create helm template
data "helm_template" "oci-kubernetes-monitoring" {
  name = "oci-kubernetes-monitoring"
  # default behavior is to use remote helm repo | var.use_local_helm_chart = false
  # the option to use local helm chart is for development purpose only
  repository        = local.repository
  chart             = local.chart
  version           = local.version
  dependency_update = true

  values = var.deploy_mushop_config ? ["${file("${path.module}/mushop_values.yaml")}"] : null

  dynamic "set" {
    for_each = local.helm_inputs
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.oci_domain == null ? {} : { "oci-onm-logan.ociDomain" = var.oci_domain }
    content {
      name  = set.key
      value = set.value
    }
  }

  count = var.generate_helm_template ? 1 : 0
}

resource "local_file" "helm_template" {
  count    = var.debug && var.generate_helm_template ? 1 : 0
  content  = jsonencode(data.helm_template.oci-kubernetes-monitoring[0])
  filename = "${path.module}/tf-debug/helm_template.json"
}