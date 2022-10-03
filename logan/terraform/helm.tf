
resource "helm_release" "la-release" {
  name  = "my-la-release"
  chart = "${path.module}/../helm-chart"
  #repository = "https://github.com/oracle-quickstart/oci-kubernetes-monitoring"

  set {
    name  = "image.url"
    value = var.oke_containerImage_url
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
    value = var.oke_namespace
  }

  set {
    name  = "ociLANamespace"
    value = var.la_namespace
  }

  set {
    name  = "ociLALogGroupID"
    value = var.la_logGroup_id
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