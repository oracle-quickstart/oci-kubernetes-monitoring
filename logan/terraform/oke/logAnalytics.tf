resource "oci_log_analytics_log_analytics_log_group" "new_log_group" {
    #Required
    compartment_id = var.oci_la_compartment_ocid
    display_name = var.oci_la_logGroup_name
    namespace = var.oci_la_namespace
    count = !var.opt_use_existing_la_logGroup && var.enable_la_resources ? 1 : 0
    description = "LogGroup for Kubernetes Logs"

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