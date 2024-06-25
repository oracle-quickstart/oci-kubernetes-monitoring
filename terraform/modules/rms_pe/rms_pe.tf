# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  private_endpoint_ocid = var.private_endpoint_ocid == null ? oci_resourcemanager_private_endpoint.rms_pe[0].id : var.private_endpoint_ocid
}

resource "oci_resourcemanager_private_endpoint" "rms_pe" {
  count          = var.private_endpoint_ocid == null ? 1 : 0
  compartment_id = var.pe_compartment_ocid
  display_name   = "oci-kubernetes-monitoring"
  vcn_id         = var.oke_vcn_ocid
  subnet_id      = var.oke_subnet_ocid

  #tags
  defined_tags  = var.tags.definedTags
  freeform_tags = var.tags.freeformTags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
    # Not a User Facing Error 
    precondition {
      condition     = var.oke_subnet_ocid != null
      error_message = <<-EOT
        Cause : This is likely a logical error with the terraform module.
        Fix   : Report the issue at https://github.com/oracle-quickstart/oci-kubernetes-monitoring/issues
        Error : var.oke_subnet_ocid is NULL in rme_pe module
      EOT
    }
  }
}

data "oci_core_subnet" "oke_subnet" {
  count     = var.oke_subnet_ocid != null ? 1 : 0
  subnet_id = var.oke_subnet_ocid

  lifecycle {
    # User Facing Error     
    postcondition {
      condition     = self.vcn_id == var.oke_vcn_ocid
      error_message = "Invalid Subnet. Subnet must be part of OKE cluster's VCN."
    }
  }
}

data "oci_resourcemanager_private_endpoint" "rms_pe" {
  count               = var.private_endpoint_ocid != null ? 1 : 0
  private_endpoint_id = var.private_endpoint_ocid

  lifecycle {
    # User Facing Error
    postcondition {
      condition     = self.vcn_id == var.oke_vcn_ocid
      error_message = "Invalid Subnet. Private Endpoint must be configured with OKE cluster's VCN."
    }
  }
}

data "oci_resourcemanager_private_endpoint_reachable_ip" "reachable_ip" {
  private_endpoint_id = local.private_endpoint_ocid
  private_ip          = var.private_ip_address
}