locals {
  # random UUID for creating unique Policy and Dynamic Group
  uuid = random_uuid.uuid.result

  # compartments
  la_compartment_name = data.oci_identity_compartment.oci_la_compartment.name
  oke_compartment_name = data.oci_identity_compartment.oke_cluster_compartment.name

  la_compartment_id = var.oci_la_compartment_ocid
  oke_compartment_id = var.oke_cluster_compartment

  # Dynmaic Group Resource
  dynamic_group_name = "dynmaicGroup-${local.uuid}"
  dynamic_group_desc = "OKE Cluster Instances running in ${local.la_compartment_name}"
  instances_in_compartment_rule = ["ALL {instance.compartment.id = '${var.oke_cluster_compartment}'}"]
  clusters_in_compartment_rule  = ["ALL {resource.type = 'cluster', resource.compartment.id = '${var.oke_cluster_compartment}'}"]
  dynamic_group_matching_rules = concat(local.instances_in_compartment_rule, local.clusters_in_compartment_rule)
  complied_dynamic_group_rules = "ANY {${join(",", local.dynamic_group_matching_rules)}}"

  # Policy
  policy_name = "policy-${local.uuid}"
  policy_desc = "Allow ${local.dynamic_group_name} to upload logs to Logging Analytics Service in ${local.la_compartment_name} compartment."
  policy_statements = [ "Allow group ${local.dynamic_group_name} to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment ${local.la_compartment_name}" ]
}

# Logging Analytics Compartment
data "oci_identity_compartment" "oci_la_compartment" {
  id = var.oci_la_compartment_ocid
}

# OKE Compartment
data "oci_identity_compartment" "oke_cluster_compartment" {
  id = var.oke_cluster_compartment
}

# Dynmaic Group
resource "oci_identity_dynamic_group" "oke_dynamic_group" {
  name           = local.dynamic_group_name
  description    = local.dynamic_group_desc
  compartment_id = var.tenancy_ocid
  matching_rule  = local.complied_dynamic_group_rules
  provider = oci.home_region

  count = var.opt_create_dynamicGroup_and_policies ? 1 : 0
}

# Policy
resource "oci_identity_policy" "oke_dynamic_group_policies" {
  name           = local.policy_name
  description    = local.policy_desc
  compartment_id = local.la_compartment_id
  statements     = local.policy_statements
  provider = oci.home_region
  
  depends_on = [oci_identity_dynamic_group.oke_dynamic_group]
  count = var.opt_create_dynamicGroup_and_policies ? 1 : 0
}

# UUID - Unique Identifier for DynamicGroup and Policy Names
resource "random_uuid" "uuid" {
}

# Outputs
output policy_name  {
  value = local.policy_name
}

output dynamic_group_name {
  value = local.dynamic_group_name
}
