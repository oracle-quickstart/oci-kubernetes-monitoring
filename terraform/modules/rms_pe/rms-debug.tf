# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "local_file" "oci_containerengine_clusters" {
  count    = var.debug ? 1 : 0
  content  = jsonencode(data.oci_containerengine_clusters.oke_clusters)
  filename = "${path.module}/tf-debug/oci_containerengine_clusters.json"
}