# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

##### Note #####
## Locals, resources and provider in this file should not depend on any other file
## so that we can move providers.tf file to a main module when it's required to run main module independent of the stack
## TODO: Main module should be able to execute idependenlty of the stack.
##          - This requirement is not met yet and is Work in progress.
##### Note #####

locals {
  # OCI Provider config
  home_region_key = data.oci_identity_tenancy.tenant_details.home_region_key
  home_region     = [for r in data.oci_identity_regions.region_map.regions : r.name if r.key == local.home_region_key][0]


  # Helm provider config
  oke_host = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["server"]

  cluster_private_ip_port = replace(local.oke_host, "https://", "")
  cluster_private_ip      = split(":", local.cluster_private_ip_port)[0]
  cluster_private_port    = split(":", local.cluster_private_ip_port)[1]

  oke_cert = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["certificate-authority-data"])

  kube_config = {
    host                   = local.use_rms_private_endpoint ? "https://${module.rms_private_endpoint[0].private_endpoint_reachable_ip}:${local.cluster_private_port}" : local.oke_host
    cluster_ca_certificate = local.use_rms_private_endpoint ? null : local.oke_cert
    cluster_id             = var.oke_cluster_ocid #yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][4]
    cluster_region         = var.region           #yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][6]
    insecure               = local.use_rms_private_endpoint
  }
}

data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "region_map" {
}

data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = var.oke_cluster_ocid
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
    insecure = local.kube_config.insecure
  }
}

provider "local" {}