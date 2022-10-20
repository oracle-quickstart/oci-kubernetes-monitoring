locals {
  # Select LogGroup OCID from 
  #  - LogGroup OCID porivded by user for an exisiting LogGroup
  #  - logaAnalytics.tf generates a new LogGroup for User
  oci_la_logGroup_id = !var.opt_use_existing_la_logGroup && var.enable_la_resources ? oci_log_analytics_log_analytics_log_group.new_log_group[0].id : var.oci_la_logGroup_id
}

resource "helm_release" "oci-kubernetes-monitoring" {
  name             = "oci-kubernetes-monitoring"
  chart            = "${path.module}/../../helm-chart"
  namespace        = var.kubernetes_namespace
  create_namespace = var.opt_create_kubernetes_namespace
  count            = var.enable_helm_release ? 1 : 0
  wait = true

  set {
    name  = "image.url"
    value = var.container_image_url
  }

  set {
    name  = "kubernetesClusterName"
    value = local.cluster_name
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
    value = local.oci_la_namespace
  }

  set {
    name  = "ociLALogGroupID"
    value = local.oci_la_logGroup_id
  }

  set {
    name  = "ociCompartmentID"
    value = var.oke_cluster_compartment
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
  chart            = "${path.module}/../../helm-chart"
  namespace        = var.kubernetes_namespace
  create_namespace = var.opt_create_kubernetes_namespace
  count            = var.enable_local_testing ? 1 : 0

  set {
    name  = "image.url"
    value = var.container_image_url
  }

  set {
    name  = "kubernetesClusterName"
    value = local.cluster_name
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
    value = local.oci_la_namespace
  }

  set {
    name  = "ociLALogGroupID"
    value = local.oci_la_logGroup_id
  }

  set {
    name  = "ociCompartmentID"
    value = var.oke_cluster_compartment
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
  count    = var.enable_local_testing ? 1 : 0
}