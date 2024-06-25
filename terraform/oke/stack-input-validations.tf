# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  oke_cluster_is_public  = local.cluster_data.endpoint_config[0].is_public_ip_enabled
  oke_cluster_is_private = !local.oke_cluster_is_public
}

# Case: User Opt to use private endpoint
resource "null_resource" "private_oke_check" {
  count = var.connect_via_private_endpoint ? 1 : 0
  lifecycle {
    # Check: Target OKE cluster should be private
    # User Facing Error
    precondition {
      condition     = local.oke_cluster_is_private
      error_message = "Invalid input. Using Private Endpoint with public OKE cluster is not allowed."
    }
  }
}

# Case: User Opt to NOT use private endpoint
resource "null_resource" "public_oke_check" {
  count = !var.connect_via_private_endpoint ? 1 : 0
  lifecycle {
    # Check: Target OKE cluster is public
    # User Facing Error
    precondition {
      condition     = local.oke_cluster_is_public
      error_message = "Missing Input. \"OKE cluster is private\" checkbox must be selected to monitor a private OKE cluster."
    }
  }
}