variable "private_endpoint_ocid" {
  type = string
  validation {
    condition     = var.private_endpoint_ocid == null ? true : length(regexall("^ocid1\\.ormprivateendpoint\\S*$", var.private_endpoint_ocid)) > 0
    error_message = "Incorrect format: var.private_endpoint_ocid"
  }
}

variable "oke_subnet_ocid" {
  type = string
  validation {
    condition     = var.oke_subnet_ocid == null ? true : length(regexall("^ocid1\\.subnet\\S*$", var.oke_subnet_ocid)) > 0
    error_message = "Incorrect format: var.oke_subnet_ocid"
  }
}

variable "pe_compartmnet_ocid" {
  type     = string
  nullable = false
}

variable "oke_vcn_ocid" {
  type = string
}

variable "private_ip_address" {
  type     = string
  nullable = false
}

variable "tags" {
  type    = object({ freeformTags = map(string), definedTags = map(string) })
  default = { "freeformTags" = {}, "definedTags" = {} }
}

locals {
  private_endpoint_ocid = var.private_endpoint_ocid == null ? oci_resourcemanager_private_endpoint.rms_pe[0].id : var.private_endpoint_ocid
}

resource "oci_resourcemanager_private_endpoint" "rms_pe" {
  count          = var.private_endpoint_ocid == null ? 1 : 0
  compartment_id = var.pe_compartmnet_ocid
  display_name   = "oke-monitoring-solution"
  vcn_id         = var.oke_vcn_ocid
  subnet_id      = var.oke_subnet_ocid

  #tags
  defined_tags  = var.tags.definedTags
  freeform_tags = var.tags.freeformTags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
    precondition {
      condition     = var.oke_subnet_ocid != null && var.oke_vcn_ocid != null && var.pe_compartmnet_ocid != null
      error_message = <<-EOT
        Private endpoint creation failed due to missing data:
                var.oke_subnet_ocid = ${var.oke_subnet_ocid}
                var.oke_vcn_ocid = ${var.oke_vcn_ocid}
                var.pe_compartmnet_ocid = ${var.pe_compartmnet_ocid}
      EOT
    }
  }
}

data "oci_resourcemanager_private_endpoint_reachable_ip" "rechable_ip" {
  private_endpoint_id = local.private_endpoint_ocid
  private_ip          = var.private_ip_address
}

output "private_endpoint_reachable_ip" {
  value = data.oci_resourcemanager_private_endpoint_reachable_ip.rechable_ip.ip_address
}