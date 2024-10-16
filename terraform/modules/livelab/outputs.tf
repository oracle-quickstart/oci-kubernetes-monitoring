# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "service_account" {
  value = local.livelab_reservationId
}

output "fluentd_base_dir_path" {
  value = local.livelab_fluentd_base_dir_path
}