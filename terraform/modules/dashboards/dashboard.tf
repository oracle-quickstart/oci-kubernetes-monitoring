# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  dashboards = ["cluster.json", "node.json", "pod.json", "workload.json", "service-type-lb.json"]
  #tags
  defined_tags  = var.tags.definedTags
  freeform_tags = var.tags.freeformTags

  template_values = {
    "compartment_ocid" = "${var.compartment_ocid}"
    "defined_tags"     = join(",", [for key, value in var.tags.definedTags : "\"${key}\": \"${value}\""])
    "freeform_tags"    = join(",", [for key, value in var.tags.freeformTags : "\"${key}\": \"${value}\""])
  }
}

resource "oci_management_dashboard_management_dashboards_import" "multi_management_dashboards_import" {
  for_each       = toset(local.dashboards)
  import_details = templatefile(format("%s/%s/%s", "${path.module}", "dashboards_json", each.value), local.template_values)
}
