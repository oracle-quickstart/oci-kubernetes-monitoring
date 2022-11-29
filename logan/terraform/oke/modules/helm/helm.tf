
data "oci_containerengine_clusters" "oke_clusters_list" {
  compartment_id = var.oke_compartment_ocid
}

locals {
  oke_clusters_list = data.oci_containerengine_clusters.oke_clusters_list.clusters
  oke_cluster_name      = var.enable_helm_release ? [for c in local.oke_clusters_list : c.name if c.id == var.oke_cluster_ocid][0] : "place-holder"
}

resource "helm_release" "oci-kubernetes-monitoring" {
  name             = "oci-kubernetes-monitoring"
  chart            = "${path.module}/../../../helm-chart"
  namespace        = var.kubernetes_namespace
  create_namespace = var.opt_create_kubernetes_namespace
  wait             = true

  count = var.enable_helm_release ? 1 : 0

  set {
    name  = "image.url"
    value = var.container_image_url
  }

  set {
    name  = "kubernetesClusterName"
    value = local.oke_cluster_name
  }

  set {
    name  = "kubernetesClusterID"
    value = var.oke_cluster_ocid
  }

  set {
    name  = "namespace"
    value = var.kubernetes_namespace
  }

  set {
    name  = "ociLANamespace"
    value = var.oci_la_namespace
  }

  set {
    name  = "ociLALogGroupID"
    value = var.oci_la_logGroup_id
  }

  set {
    name  = "ociCompartmentID"
    value = var.oke_compartment_ocid
  }

  set {
    name  = "fluentd.baseDir"
    value = var.fluentd_baseDir_path
  }
}

# helm template for release artifacts testing and validation
# this resouece is not used by helm release
data "helm_template" "oci-kubernetes-monitoring" {
  name             = "oci-kubernetes-monitoring"
  chart            = "${path.module}/../../../helm-chart"
  namespace        = var.kubernetes_namespace
  create_namespace = var.opt_create_kubernetes_namespace

  count = var.enable_helm_debugging ? 1 : 0

  set {
    name  = "image.url"
    value = var.container_image_url
  }

  set {
    name  = "kubernetesClusterName"
    value = local.oke_cluster_name
  }

  set {
    name  = "kubernetesClusterID"
    value = var.oke_cluster_ocid
  }

  set {
    name  = "namespace"
    value = var.kubernetes_namespace
  }

  set {
    name  = "ociLANamespace"
    value = var.oci_la_namespace
  }

  set {
    name  = "ociLALogGroupID"
    value = var.oci_la_logGroup_id
  }

  set {
    name  = "ociCompartmentID"
    value = var.oke_compartment_ocid
  }

  set {
    name  = "fluentd.baseDir"
    value = var.fluentd_baseDir_path
  }
}

# Helm release artifacts for local testing and validation. Not used by helm resource.
resource "local_file" "helm_release" {
  content  = tostring(data.helm_template.oci-kubernetes-monitoring[0].manifest)
  filename = "${path.module}/local/helmrelease.yaml"
  count    = var.enable_helm_debugging ? 1 : 0
}

# kubeconfig when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "oke_kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke[0].content
  filename = "${path.module}/local/kubeconfig"
  count    = var.enable_helm_debugging && var.enable_helm_release ? 1 : 0
}
