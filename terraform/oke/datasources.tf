# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_user" "livelab_user" {
  user_id = var.current_user_ocid
}

data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "region_map" {
}

data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = var.oke_cluster_ocid
}