# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

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