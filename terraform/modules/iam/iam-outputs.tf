# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "oke_dynamic_group_ocid" {
  value = oci_identity_dynamic_group.oke_dynamic_group.id
}

output "oke_monitoring_policy_ocid" {
  value = oci_identity_policy.oke_monitoring_policy.id
}