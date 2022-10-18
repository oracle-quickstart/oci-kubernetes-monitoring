data "oci_objectstorage_namespace" "tenant_namespace" {
    compartment_id = var.tenancy_ocid # tenancy ocid
}

data "oci_log_analytics_namespace" "tenant_namespace" {
    namespace = data.oci_objectstorage_namespace.tenant_namespace.namespace
}