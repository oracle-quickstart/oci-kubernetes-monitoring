# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Case: User Opt to NOT create a new log group
resource "null_resource" "user_opts_out_to_create_log_group_check" {
  count = !var.opt_create_new_la_log_group ? 1 : 0
  lifecycle {
    # Not a User Facing Error
    # Check: User has provided an existing log group id
    precondition {
      condition     = var.log_group_ocid != null
      error_message = "var.log_group_ocid must be set to a valid value when var.opt_create_new_la_log_group is false."
    }
  }
}