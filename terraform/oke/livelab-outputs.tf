# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  url_prefix             = "https://cloud.oracle.com/loganalytics/dashboards?id=dashboardHome"
  url_compartment_prefix = "&comp="
  url_region_prefix      = "&region="
  dashbords_button_link  = join("", [local.url_prefix, local.url_compartment_prefix, var.oci_onm_compartment_ocid, local.url_region_prefix, var.region])
}

output "dashbords_button_link" {
  value = var.livelab_switch ? local.dashbords_button_link : null
}
