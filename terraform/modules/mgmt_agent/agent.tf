# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  freeform_tags = module.format_tags.freeform_tags_string
  defined_tags  = module.format_tags.defined_tags_string
  inputRspFileContent = (var.deploy_jms_plugin ?
    base64encode(join("\n", [
      base64decode(trimspace(data.external.agent_plugin_config[0].result.content)),
      "AgentDisplayName = k8_mgmt_agent-${var.uniquifier}",
      "FreeFormTags = ${local.freeform_tags}",
      "DefinedTags = ${local.defined_tags}"
    ])) :
    base64encode(join("\n", [
      "ManagementAgentInstallKey = ${oci_management_agent_management_agent_install_key.Kubernetes_AgentInstallKey.key}",
      "AgentDisplayName = k8_mgmt_agent-${var.uniquifier}",
      "FreeFormTags = ${local.freeform_tags}",
      "DefinedTags = ${local.defined_tags}"
    ]))
  )
}

data "external" "agent_plugin_config" {
  count = var.deploy_jms_plugin ? 1 : 0
  program = ["bash", "${path.module}/resources/generate_jms_plugin_config.sh"]

  query = {
    fleet_ocid    = var.jms_fleet_ocid
    install_key = oci_management_agent_management_agent_install_key.Kubernetes_AgentInstallKey.id
  }
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