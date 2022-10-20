locals {
  home_region = [for s in data.oci_identity_region_subscriptions.regions.region_subscriptions : s.region_name if s.is_home_region == true][0]
}

data "oci_identity_region_subscriptions" "regions" {
  tenancy_id = var.tenancy_ocid
}


