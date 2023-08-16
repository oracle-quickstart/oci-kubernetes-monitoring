# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_containerengine_clusters" "oke_clusters_list" {
  compartment_id = var.oke_compartment_ocid
}

locals {
  oke_clusters_list = data.oci_containerengine_clusters.oke_clusters_list.clusters
  oke_cluster_name  = [for c in local.oke_clusters_list : c.name if c.id == var.oke_cluster_ocid][0]

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
  chart             = var.helm_abs_path
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
    for_each = var.deploy_mushop_config ? local.mushop_helm_inputs : {}
    content {
      name  = set.key
      value = set.value
    }
  }

  count = var.generate_helm_template ? 0 : 1
}

# Create helm template
data "helm_template" "oci-kubernetes-monitoring" {
  name              = "oci-kubernetes-monitoring"
  chart             = var.helm_abs_path
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
    for_each = var.deploy_mushop_config ? local.mushop_helm_inputs : {}
    content {
      name  = set.key
      value = set.value
    }
  }

  count = var.generate_helm_template ? 1 : 0
}

# Helm release artifacts for local testing and validation. Not used by helm resource.
resource "local_file" "helm_release" {
  content  = tostring(data.helm_template.oci-kubernetes-monitoring[0].manifest)
  filename = "${path.module}/local/helmrelease.yaml"
  count    = var.generate_helm_template ? 1 : 0
}