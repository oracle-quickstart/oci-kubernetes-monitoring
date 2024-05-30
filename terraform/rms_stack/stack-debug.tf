resource "local_file" "tenant_details" {
  count    = var.debug ? 1 : 0
  content  = jsonencode(data.oci_identity_tenancy.tenant_details)
  filename = "${path.module}/tf-debug/tenant_details.json"
}

resource "local_file" "region_map" {
  count    = var.debug ? 1 : 0
  content  = jsonencode(data.oci_identity_regions.region_map)
  filename = "${path.module}/tf-debug/region_map.json"
}

resource "local_file" "kube_config" {
  count    = var.debug ? 1 : 0
  content  = yamlencode(yamldecode(data.oci_containerengine_cluster_kube_config.oke.content))
  filename = "${path.module}/tf-debug/kube_config.yaml"
}

# data "oci_containerengine_clusters" "oke_clusters" {
#   compartment_id = var.oke_compartment_ocid
# }


# data "oci_identity_tenancy" "tenant_details" {
#   tenancy_id = var.tenancy_ocid
# }

# data "oci_identity_regions" "region_map" {
# }

# data "oci_containerengine_cluster_kube_config" "oke" {
#   cluster_id = var.oke_cluster_ocid
# }