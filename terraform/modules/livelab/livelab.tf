# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  oci_username                 = data.oci_identity_user.livelab_user.name
  livelab_res_num              = trimprefix(trimsuffix(lower(local.oci_username), "-user"), "ll")
  livelab_reservationId        = "resr${local.livelab_res_num}"
  livelab_fluentd_baseDir_path = "/var/log/${local.livelab_reservationId}"
}

data "oci_identity_user" "livelab_user" {
  user_id = var.current_user_ocid
}