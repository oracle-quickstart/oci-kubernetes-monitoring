# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  helm_repo_url = "https://oracle-quickstart.github.io/oci-kubernetes-monitoring"
  chart_name    = "oci-onm"

  k8s_namespace = var.deploy_mushop_config ? "livelab-test" : var.kubernetes_namespace

  repository = var.use_local_helm_chart ? null : local.helm_repo_url
  chart      = var.use_local_helm_chart ? var.helm_abs_path : local.chart_name
  version    = var.use_local_helm_chart ? null : var.helmchart_version == null ? null : var.helmchart_version

  helm_inputs = {
    # global
    "global.namespace"             = local.k8s_namespace
    "global.kubernetesClusterID"   = var.oke_cluster_ocid
    "global.kubernetesClusterName" = var.oke_cluster_name

    # oci-onm-logan
    "oci-onm-logan.ociLANamespace"  = var.oci_la_namespace
    "oci-onm-logan.ociLALogGroupID" = var.oci_la_logGroup_id
    "oci-onm-logan.fluentd.baseDir" = var.fluentd_baseDir_path

    #oci-onm-mgmt-agent
    "oci-onm-mgmt-agent.mgmtagent.installKeyFileContent" = var.mgmt_agent_install_key_content
    "oci-onm-mgmt-agent.deployMetricServer"              = var.opt_deploy_metric_server
  }

  mushop_helm_inputs = {
    # oci-onm-logan
    "createServiceAccount" = false
    "serviceAccount"       = var.livelab_service_account
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
  force_update      = true
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
    for_each = var.oke_cluster_entity_ocid == "DEFAULT" ? [] : ["run_once"]
    content {
      name  = "oci-onm-logan.ociLAClusterEntityID"
      value = var.oke_cluster_entity_ocid
    }
  }

  dynamic "set" {
    for_each = var.deploy_mushop_config ? local.mushop_helm_inputs : {}
    content {
      name  = set.key
      value = set.value
    }
  }

  count = var.install_helm ? 1 : 0
}

# Create helm template
data "helm_template" "oci-kubernetes-monitoring" {
  name = "oci-kubernetes-monitoring"
  # default behaviour is to use remote helm repo | var.use_local_helm_chart = false
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
    for_each = var.oke_cluster_entity_ocid == "DEFAULT" ? [] : ["run_once"]
    content {
      name  = "oci-onm-logan.ociLAClusterEntityID"
      value = var.oke_cluster_entity_ocid
    }
  }

  dynamic "set" {
    for_each = var.deploy_mushop_config ? local.mushop_helm_inputs : {}
    content {
      name  = set.key
      value = set.value
    }
  }

  count = var.generate_helm_template ? 1 : 0
}
