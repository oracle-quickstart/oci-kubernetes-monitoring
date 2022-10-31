output "cluster_name" {
  value = local.cluster_name
}

output "policy_name" {
  value = oci_identity_policy.oke_dynamic_group_policies[0].name
}

output "dynamic_group_name" {
  value = oci_identity_dynamic_group.oke_dynamic_group[0].name
}