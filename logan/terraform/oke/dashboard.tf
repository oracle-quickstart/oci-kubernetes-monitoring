locals {
  dashboard_files = var.enable_dashboard_import ? ["oke_cluster_summary.json"] : []
}

resource "oci_management_dashboard_management_dashboards_import" "multiple_dashboard_files" {
  for_each       = toset(local.dashboard_files)
  import_details = templatefile(format("%s/%s/%s", "${path.module}", "dashboards", each.value), { "compartment_ocid" : "${var.oci_la_compartment_ocid}" })
}