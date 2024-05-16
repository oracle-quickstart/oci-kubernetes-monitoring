resource "local_file" "oke" {
  count    = var.debug ? 1 : 0
  content  = jsonencode(data.oci_containerengine_cluster_kube_config.oke)
  filename = "${path.module}/tf-debug/oci_containerengine_cluster_kube_config.json"
}

resource "local_file" "oke_clusters" {
  count    = var.debug ? 1 : 0
  content  = jsonencode(data.oci_containerengine_clusters.oke_clusters)
  filename = "${path.module}/tf-debug/oci_containerengine_clusters.json"
}

resource "local_file" "rms_pe" {
  count    = var.debug ? 1 : 0
  content  = jsonencode(data.oci_resourcemanager_private_endpoint_reachable_ip.rms_pe)
  filename = "${path.module}/tf-debug/oci_resourcemanager_private_endpoint_reachable_ip.json"
}