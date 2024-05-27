# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  dashboards = ["cluster.json", "node.json", "pod.json", "workload.json", "service-type-lb.json"]

  #tags
  defined_tags  = module.format_tags.defined_tags_string
  freeform_tags = module.format_tags.freeform_tags_string

  template_values = {
    "compartment_ocid" = "${var.compartment_ocid}"

    # Expected format of tags: https://docs.oracle.com/en-us/iaas/api/#/en/managementdashboard/20200901/ManagementDashboardImportDetails/
    "defined_tags"  = local.defined_tags
    "freeform_tags" = local.freeform_tags
  }
}

module "format_tags" {
  source = "./format_tags"
  tags   = var.tags
}

resource "oci_management_dashboard_management_dashboards_import" "multi_management_dashboards_import" {
  for_each       = toset(local.dashboards)
  import_details = templatefile(format("%s/%s/%s", "${path.module}", "dashboards_json", each.value), local.template_values)
}

resource "local_file" "dashboard_template" {
  for_each = var.debug ? toset(local.dashboards) : []
  content  = templatefile(format("%s/%s/%s", "${path.module}", "dashboards_json", each.value), local.template_values)
  filename = "${path.module}/tf-debug/${each.value}"
}