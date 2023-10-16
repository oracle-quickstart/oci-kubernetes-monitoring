# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_containerengine_clusters" "oke_clusters_list" {
  compartment_id = var.oke_compartment_ocid
}

locals {
  helm_repo_url   = "https://oracle-quickstart.github.io/oci-kubernetes-monitoring"
  helm_repo_chart = "oci-onm"

  oke_clusters_list = data.oci_containerengine_clusters.oke_clusters_list.clusters
  oke_cluster_name = var.oke_cluster_name == "DEFAULT" ? [for c in local.oke_clusters_list :
  c.name if c.id == var.oke_cluster_ocid][0] : var.oke_cluster_name
  oke_cluster_entity_ocid = var.oke_cluster_entity_ocid == "DEFAULT" ? null : var.oke_cluster_entity_ocid

  helm_inputs = {
    # global
    "global.namespace"             = var.deploy_mushop_config ? "livelab-test" : var.kubernetes_namespace
    "global.kubernetesClusterID"   = var.oke_cluster_ocid
    "global.kubernetesClusterName" = local.oke_cluster_name

    # oci-onm-logan
    "oci-onm-logan.ociLANamespace"  = var.oci_la_namespace
    "oci-onm-logan.ociLALogGroupID" = var.oci_la_logGroup_id
    "oci-onm-logan.image.url"       = var.logan_container_image_url
    "oci-onm-logan.fluentd.baseDir" = var.fluentd_baseDir_path

    #oci-onm-mgmt-agent
    "oci-onm-mgmt-agent.mgmtagent.installKeyFileContent" = var.mgmt_agent_install_key_content
    "oci-onm-mgmt-agent.mgmtagent.image.url"             = var.mgmt_agent_container_image_url
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
  repository        = var.use_local_helm_chart ? null : local.helm_repo_url
  chart             = var.use_local_helm_chart ? var.helm_abs_path : local.helm_repo_chart
  wait              = true
  dependency_update = true
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
  name              = "oci-kubernetes-monitoring"
  # default behaviour is to use remote helm repo | var.use_local_helm_chart = false
  # the option to use local helm chart is for development purpose only
  repository        = var.use_local_helm_chart ? null : local.helm_repo_url
  chart             = var.use_local_helm_chart ? var.helm_abs_path : local.helm_repo_chart
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