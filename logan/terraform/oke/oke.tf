locals {
  oke_clusters_list = data.oci_containerengine_clusters.oke_clusters_list.clusters
  cluster_name      = [for c in local.oke_clusters_list : c.name if c.id == var.oke_cluster_ocid][0]
}

data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = var.oke_cluster_ocid
}

data "oci_containerengine_clusters" "oke_clusters_list" {
  compartment_id = var.oke_compartment_ocid
}

# kubeconfig when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "oke_kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke.content
  filename = "${path.module}/local/kubeconfig"
  count    = var.enable_debugging ? 1 : 0
}