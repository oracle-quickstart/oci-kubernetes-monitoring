resource "oci_log_analytics_log_analytics_log_group" "new_log_group" {
    #Required
    compartment_id = var.oci_la_compartment_ocid
    display_name = var.oci_la_logGroup_name
    namespace = var.oci_la_namespace
    count = var.opt_use_existing_la_logGroup ? 0 : 1
    description = "LogGroup for Kubernetes Logs"
}