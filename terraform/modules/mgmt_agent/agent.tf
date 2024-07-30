# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  install_key   = oci_management_agent_management_agent_install_key.Kubernetes_AgentInstallKey.key
  freeform_tags = module.format_tags.freeform_tags_string
  defined_tags  = module.format_tags.defined_tags_string
  inputRspFileContent = base64encode(join("\n", [
    "ManagementAgentInstallKey = ${local.install_key}",
    "AgentDisplayName = k8_mgmt_agent-${var.uniquifier}",
    "FreeFormTags = ${local.freeform_tags}",
    "DefinedTags = ${local.defined_tags}"
  ]))
}

output "defined_tags_string" {
  value = module.format_tags.defined_tags_string
}

output "freeform_tags_string" {
  value = module.format_tags.freeform_tags_string
}

# format tags; as required in Agent Response file
module "format_tags" {
  source = "./format_tags"
  tags   = var.tags
}

resource "oci_management_agent_management_agent_install_key" "Kubernetes_AgentInstallKey" {
  compartment_id = var.compartment_ocid
  display_name   = "k8_mgmt_agent_key-${var.uniquifier}"
  time_expires   = timeadd(timestamp(), "8760h") # 1 year

  lifecycle {
    ignore_changes = [time_expires]
  }
}