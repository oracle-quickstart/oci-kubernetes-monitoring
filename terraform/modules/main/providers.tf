# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "region_map" {
}

data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = var.oke_cluster_ocid
}

locals {
  home_region_key = data.oci_identity_tenancy.tenant_details.home_region_key
  home_region     = [for r in data.oci_identity_regions.region_map.regions : r.name if r.key == local.home_region_key][0]

  kube_config = {
    host                   = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["server"]
    cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["certificate-authority-data"])
    cluster_id             = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][4]
    cluster_region         = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][6]
  }
}

provider "oci" {
  tenancy_ocid     = var.boat_auth ? var.boat_tenancy_ocid : var.tenancy_ocid
  region           = var.region
  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  user_ocid        = var.user_ocid
}

provider "oci" {
  alias            = "home_region"
  tenancy_ocid     = var.boat_auth ? var.boat_tenancy_ocid : var.tenancy_ocid
  region           = local.home_region
  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  user_ocid        = var.user_ocid
}

provider "helm" {
  kubernetes {
    host                   = local.kube_config.host
    cluster_ca_certificate = local.kube_config.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args = ["ce", "cluster", "generate-token", "--cluster-id",
      local.kube_config.cluster_id, "--region", local.kube_config.cluster_region]
      command = "oci"
    }
    insecure = false #TODO
  }
}