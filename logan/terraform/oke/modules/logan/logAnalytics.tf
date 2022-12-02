data "oci_objectstorage_namespace" "tenant_namespace" {
  compartment_id = var.tenancy_ocid # tenancy ocid
}

data "oci_log_analytics_namespace" "la_namespace" {
  namespace = data.oci_objectstorage_namespace.tenant_namespace.namespace
}

locals  {
  oci_la_namespace = data.oci_log_analytics_namespace.la_namespace.namespace
  final_oci_la_logGroup_id = var.create_new_logGroup ? oci_log_analytics_log_analytics_log_group.new_log_group[0].id : var.existing_logGroup_id
}

resource "oci_log_analytics_log_analytics_log_group" "new_log_group" {
  compartment_id = var.compartment_ocid
  display_name   = var.new_logGroup_name
  namespace      = local.oci_la_namespace
  description    = "LogGroup for Kubernetes Logs"

  count = var.create_new_logGroup ? 1 : 0

  # Preconditions are supported in terraform v 1.2.0+
  # Resource Manager supports 1.1.x as of Oct 18th, 2022
  #

  # lifecycle {
  #     precondition {
  #         condition     = data.oci_log_analytics_namespace.tenant_namespace.is_onboarded == true
  #         error_message = "Tenancy is not on-boarded to OCI Logging Analytics Service in ${var.region} region."
  #     }
  # }
}