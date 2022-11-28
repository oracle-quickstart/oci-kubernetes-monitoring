locals {
  # Compartments
  root_compartment_ocid = var.tenancy_ocid
  la_compartment_name   = data.oci_identity_compartment.oci_la_compartment.name
  oke_compartment_name  = data.oci_identity_compartment.oke_compartment.name

  # Dynmaic Group
  uuid_dynamic_group            = md5(var.oke_cluster_ocid)
  dynamic_group_name            = "OKE-${local.uuid_dynamic_group}"
  dynamic_group_desc            = "Auto-Generated by Resource Manager. Required for monitoring OKE Cluster, ${local.cluster_name}, in ${local.oke_compartment_name} compartment."
  instances_in_compartment_rule = ["ALL {instance.compartment.id = '${var.oke_compartment_ocid}'}"]
  clusters_in_compartment_rule  = ["ALL {resource.type = 'cluster', resource.compartment.id = '${var.oke_compartment_ocid}'}"]
  dynamic_group_matching_rules  = concat(local.instances_in_compartment_rule, local.clusters_in_compartment_rule)
  complied_dynamic_group_rules  = "ANY {${join(",", local.dynamic_group_matching_rules)}}"

  # Policy
  uuid_policy       = md5("${local.dynamic_group_name}${local.la_compartment_name}")
  policy_name       = "KubernetesMonitoringPolicy_${local.uuid_policy}"
  policy_desc       = "Auto-Generated by Resource Manager. Allows OKE Dynamic Group, ${local.dynamic_group_name}, to upload data to Logging Analytics Service in ${local.la_compartment_name} compartment."
  policy_statements = ["Allow dynamic-group ${local.dynamic_group_name} to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment ${local.la_compartment_name}"]

}

# Logging Analytics Compartment
data "oci_identity_compartment" "oci_la_compartment" {
  id = var.oci_la_compartment_ocid
}

# OKE Compartment
data "oci_identity_compartment" "oke_compartment" {
  id = var.oke_compartment_ocid
}

# Dynmaic Group
resource "oci_identity_dynamic_group" "oke_dynamic_group" {
  name           = local.dynamic_group_name
  description    = local.dynamic_group_desc
  compartment_id = local.root_compartment_ocid
  matching_rule  = local.complied_dynamic_group_rules
  provider       = oci.home_region

  count = var.opt_create_dynamicGroup_and_policies ? 1 : 0
}

# Policy
resource "oci_identity_policy" "oke_monitoring_policy" {
  name           = local.policy_name
  description    = local.policy_desc
  compartment_id = var.oci_la_compartment_ocid
  statements     = local.policy_statements
  provider       = oci.home_region

  depends_on = [oci_identity_dynamic_group.oke_dynamic_group]
  count      = var.opt_create_dynamicGroup_and_policies ? 1 : 0
}