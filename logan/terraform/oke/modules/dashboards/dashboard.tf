locals {
  dashboards = ["cluster.json", "node.json", "pod.json", "workload.json"]
}

resource "oci_management_dashboard_management_dashboards_import" "multi_management_dashboards_import" {
  for_each       = toset(local.dashboards)
  import_details = templatefile(format("%s/%s/%s", "${path.module}", "dashboards_json", each.value), { "compartment_ocid" : "${var.oci_management_dashboard_compartment_ocid}" })
}