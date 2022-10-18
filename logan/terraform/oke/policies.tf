# Dynmaic Group
resource "oci_identity_dynamic_group" "oke_dynamic_group" {
    #Required
    compartment_id = var.tenancy_ocid
    description = "Required for sending data from OKE Cluster to OCI Logging Analytics"
    matching_rule = "ANY {${join(",", local.dynamic_group_matching_rules)}}"
    name = "${local.la_compartment_name}_DynamicGroup"

    provider = oci.home_region

    count = var.opt_create_dynamicGroup_and_policies ? 1 : 0

}

# Policy
resource "oci_identity_policy" "oke_dynamic_group_policies" {
  name           = "${local.la_compartment_name}_DynamicGroup_Policy"
  description    = "Allow ${local.la_compartment_name}_DynamicGroup to upload logs to Logging Analytics Service"
  compartment_id = var.oci_la_compartment_ocid # Place policy at tenant level
  statements     = ["Allow group OCI_Kubernetes_Monitoring_DynamicGroup to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment ${local.la_compartment_name}"]

  depends_on = [oci_identity_dynamic_group.oke_dynamic_group]

  provider = oci.home_region

  count = var.opt_create_dynamicGroup_and_policies ? 1 : 0
}

# Logging Analytics Compartment
data "oci_identity_compartment" "oci_la_compartment" {
    id = var.oci_la_compartment_ocid
}

# Logging Analytics Compartment Name
locals {
    la_compartment_name = data.oci_identity_compartment.oci_la_compartment.name
}

# Concat Matching Rules
locals  {
    dynamic_group_matching_rules =  concat(
    local.instances_in_compartment_rule,
    local.clusters_in_compartment_rule
    )
}

# Individual Rules
locals {
  instances_in_compartment_rule    = ["ALL {instance.compartment.id = '${var.oke_cluster_compartment}'}"]
  clusters_in_compartment_rule     = ["ALL {resource.type = 'cluster', resource.compartment.id = '${var.oke_cluster_compartment}'}"]
}
