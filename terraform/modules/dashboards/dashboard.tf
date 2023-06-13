# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  dashboards = ["cluster.json", "node.json", "pod.json", "workload.json", "service-type-lb.json"]
}

resource "oci_management_dashboard_management_dashboards_import" "multi_management_dashboards_import" {
  for_each       = toset(local.dashboards)
  import_details = templatefile(format("%s/%s/%s", "${path.module}", "dashboards_json", each.value), { "compartment_ocid" : "${var.compartment_ocid}" })
}
