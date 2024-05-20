resource "null_resource" "validate_inputs" {
  # Any change in trigger will re-create the resource hence trigger re-check of pre-conditions

  # Map of arbitray strings
  triggers = {
    a = var.user_provided_oke_cluster_entity_ocid,
    b = var.new_oke_entity_name,
    c = var.user_provided_oci_la_logGroup_ocid,
    d = var.new_logGroup_name
  }

  lifecycle {
    precondition {
      condition = ((var.user_provided_oke_cluster_entity_ocid == null && var.new_oke_entity_name != null) ||
      (var.user_provided_oke_cluster_entity_ocid != null && var.new_oke_entity_name == null))
      error_message = <<-EOT
        Logical Error: 
        Only of the inputs [user_provided_oke_cluster_entity_ocid, new_oke_entity_name] must be set and other should be null.
      EOT
    }

    precondition {
      condition = ((var.user_provided_oci_la_logGroup_ocid == null && var.new_logGroup_name != null) ||
      (var.user_provided_oci_la_logGroup_ocid != null && var.new_logGroup_name == null))
      error_message = <<-EOT
        Logical Error: 
        Only of the inputs [user_provided_oci_la_logGroup_ocid, new_logGroup_name] must be set and other should be null.
      EOT
    }

    # precondition {
    #   condition = ((var.user_provided_oci_la_logGroup_ocid == null && var.new_logGroup_name != null) ||
    #   (var.user_provided_oci_la_logGroup_ocid != null && var.new_logGroup_name == null))
    #   error_message = <<-EOT
    #     Logical Error: 
    #     Only of the inputs [user_provided_oci_la_logGroup_ocid,new_logGroup_name] must be set and other should be null.
    #     var.user_provided_oci_la_logGroup_ocid = ${var.user_provided_oci_la_logGroup_ocid}
    #     var.new_logGroup_name = ${var.new_logGroup_name}
    #   EOT
    # }

  }
}