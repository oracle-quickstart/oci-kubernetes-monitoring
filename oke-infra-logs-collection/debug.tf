# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "local_file" "invoke_raw_request_script" {
  count    = var.debug ? 1 : 0
  content  = jsonencode(local.oci_logging_log_data)
  filename = "${path.module}/oci_logging_log_data.json"
}