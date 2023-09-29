# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  installKey          = oci_management_agent_management_agent_install_key.Kubernetes_AgentInstallKey.key
  inputRspFileContent = base64encode(join("\n", ["ManagementAgentInstallKey = ${local.installKey}", "AgentDisplayName = k8_mgmt_agent-${var.uniquifier}"]))
}

resource "oci_management_agent_management_agent_install_key" "Kubernetes_AgentInstallKey" {
  compartment_id = var.compartment_ocid
  display_name   = "k8_mgmt_agent_key-${var.uniquifier}"
  time_expires   = timeadd(timestamp(), "8760h") # 1 year

  lifecycle {
    ignore_changes = [ time_expires ]
  }
}