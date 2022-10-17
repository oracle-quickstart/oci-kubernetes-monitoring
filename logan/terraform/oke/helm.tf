locals  {
  oci_la_logGroup_id = var.opt_use_existing_la_logGroup ? var.oci_la_logGroup_id : oci_log_analytics_log_analytics_log_group.new_log_group[0].id
}

resource "helm_release" "oci-kubernetes-monitoring" {
  name  = "oci-kubernetes-monitoring"
  chart = "${path.module}/../../helm-chart"
  namespace = var.kubernetes_namespace
  create_namespace = var.opt_create_kubernetes_namespace

  set {
    name  = "image.url"
    value = var.container_image_url
  }

  set {
    name  = "kubernetesClusterName"
    value = var.oke_cluster_name
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

data "helm_template" "oci-kubernetes-monitoring" {
  name  = "oci-kubernetes-monitoring"
  chart = "${path.module}/../../helm-chart"
  namespace = var.kubernetes_namespace
  create_namespace = var.opt_create_kubernetes_namespace

  set {
    name  = "image.url"
    value = var.container_image_url
  }

  set {
    name  = "kubernetesClusterName"
    value = var.oke_cluster_name
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

# kubeconfig when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "helm_release" {
  content  = tostring(data.helm_template.oci-kubernetes-monitoring.manifest)
  filename = "${path.module}/gitignore/helmrelease.yaml"
}