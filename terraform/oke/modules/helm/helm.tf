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
    "global.namespace" = var.kubernetes_namespace
    "global.kubernetesClusterID" = var.oke_cluster_ocid

    # oci-onm-logan
    "oci-onm-logan.ociLANamespace" = var.oci_la_namespace
    "oci-onm-logan.ociLALogGroupID" = var.oci_la_logGroup_id
    "oci-onm-logan.image.url" = var.container_image_url
    "oci-onm-logan.kubernetesClusterName" = local.oke_cluster_name
    "oci-onm-logan.image.url" = var.container_image_url
    "oci-onm-logan.fluentd.baseDir" = var.fluentd_baseDir_path

    #oci-onm-mgmt-agent
    "oci-onm-mgmt-agent.mgmtagent.installKeyFileContent" = var.installKeyFileContent
    "oci-onm-mgmt-agent.mgmtagent.image.url" = var.macs_agent_image_url
  }

}

resource "helm_release" "oci-kubernetes-monitoring" {
  name             = "oci-kubernetes-monitoring"
  chart            = "${path.root}/../../charts/oci-onm"
  wait             = true
  dependency_update = true
  atomic = true

  count = var.enable_helm_debugging ? 0 : 1

  dynamic set {
    for_each = local.helm_inputs
    content {
      name = set.key
      value = set.value
    }
  }
}

data "helm_template" "oci-kubernetes-monitoring" {
  name             = "oci-kubernetes-monitoring"
  chart            = "${path.root}/../../charts/oci-onm"
  dependency_update = true

  count = var.enable_helm_debugging ? 1 : 0

  dynamic set {
    for_each = local.helm_inputs
    content {
      name = set.key
      value = set.value
    }
  }
}

# Helm release artifacts for local testing and validation. Not used by helm resource.
resource "local_file" "helm_release" {
  content  = tostring(data.helm_template.oci-kubernetes-monitoring[0].manifest)
  filename = "${path.module}/local/helmrelease.yaml"
  count    =  var.enable_helm_debugging ? 1 : 0
}