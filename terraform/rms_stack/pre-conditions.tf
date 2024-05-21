# Pre-conditions are not suppoted by RMS terraform version (May 2024)
# https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Reference/terraformversions.htm

# data "oci_core_subnet" "oke_subnet" {
#   count     = var.oke_is_private && local.user_provided_subnet_ocid != null ? 1 : 0
#   subnet_id = local.user_provided_subnet_ocid
# }

# data "oci_resourcemanager_private_endpoint" "pe" {
#   count               = var.oke_is_private && local.user_provided_pe_ocid != null ? 1 : 0
#   private_endpoint_id = local.user_provided_pe_ocid
# }

# resource "null_resource" "validate_stack_inputs" {
#   # Any change in trigger will re-create the resource hence trigger re-check of pre-conditions

#   # Map of arbitray strings
#   triggers = {
#     user_provided_subnet_ocid = local.user_provided_subnet_ocid
#   }

#   lifecycle {
#     precondition {
#       condition     = !var.oke_is_private || (local.user_provided_subnet_ocid == null || data.oci_core_subnet.oke_subnet[0].vcn_id == local.oke_vcn_id)
#       error_message = <<-EOT
#         Incorrect Subnet Error:
#         Subnet: ${local.user_provided_subnet_ocid} is not part of OKE VCN: ${local.oke_vcn_id}
#       EOT
#     }

#     precondition {
#       condition     = !var.oke_is_private || (local.user_provided_pe_ocid == null || data.oci_resourcemanager_private_endpoint.pe[0].vcn_id == local.oke_vcn_id)
#       error_message = <<-EOT
#         Incorrect Private Endpoint Error:
#         Private Endpoint: ${local.user_provided_pe_ocid} is not part of OKE VCN: ${local.oke_vcn_id}
#       EOT
#     }
#   }
# }