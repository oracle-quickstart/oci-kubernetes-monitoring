# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 1.0.0, <= 1.6"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.96.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

locals {
  home_region_key = data.oci_identity_tenancy.tenant_details.home_region_key
  home_region     = var.livelab_switch ? "us-phoenix-1" : [for r in data.oci_identity_regions.region_map.regions : r.name if r.key == local.home_region_key][0]
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
    host                   = module.oke.helm_config.host
    cluster_ca_certificate = module.oke.helm_config.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args = ["ce", "cluster", "generate-token", "--cluster-id",
      module.oke.helm_config.cluster_id, "--region", module.oke.helm_config.cluster_region]
      command = "oci"
    }
    insecure = module.oke.helm_config.insecure
  }
}

