locals {
  dashboard_files = ["cluster.json", "node.json", "pod.json", "workload.json"]
}

resource "oci_management_dashboard_management_dashboards_import" "multiple_dashboard_files" {
  for_each       = toset(local.dashboard_files)
  import_details = templatefile(format("%s/%s/%s", "${path.module}", "dashboards_json", each.value), { "compartment_ocid" : "${var.oci_dashboard_compartment_ocid}" })
}