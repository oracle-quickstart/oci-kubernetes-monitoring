# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  url_prefix             = "https://cloud.oracle.com/loganalytics/dashboards?id=dashboardHome"
  url_compartment_prefix = "%26comp%3D"
  url_region_prefix      = "%26region%3D"
  dashbords_button_link  = join("", [local.url_prefix, local.url_compartment_prefix, var.oci_onm_compartment_ocid, local.url_region_prefix, var.region])
}

output "dashbords_button_link" {
  value = var.livelab_switch ? local.url_prefix : null
}
