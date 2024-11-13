resource "local_file" "oci_containerengine_clusters" {
  count    = var.debug ? 1 : 0
  content  = jsonencode(data.oci_containerengine_clusters.oke_clusters)
  filename = "${path.module}/tf-debug/oci_containerengine_clusters.json"
}