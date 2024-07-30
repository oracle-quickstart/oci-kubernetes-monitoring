# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "local_file" "inputRspFileContent" {
  count    = var.debug ? 1 : 0
  content  = base64decode(local.inputRspFileContent)
  filename = "${path.module}/tf-debug/inputRspFileContent.txt"
}