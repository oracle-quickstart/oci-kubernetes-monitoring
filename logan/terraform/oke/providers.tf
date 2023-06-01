# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = "~> 1.0.0, < 1.1"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.96.0"
      # https://registry.terraform.io/providers/hashicorp/oci/4.85.0
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
      # https://registry.terraform.io/providers/hashicorp/helm/2.1.0
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
      # https://registry.terraform.io/providers/hashicorp/local/2.1.0
    }
  }
}

# https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm
provider "oci" {
  tenancy_ocid = var.boat_auth ? var.boat_tenancy_ocid : var.tenancy_ocid
  region       = var.region

  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  user_ocid        = var.user_ocid
}

data "oci_identity_region_subscriptions" "regions" {
  tenancy_id = var.tenancy_ocid
}

locals {
  home_region = [for s in data.oci_identity_region_subscriptions.regions.region_subscriptions : s.region_name if s.is_home_region == true][0]
}

provider "oci" {
  alias        = "home_region"
  tenancy_ocid = var.boat_auth ? var.boat_tenancy_ocid : var.tenancy_ocid
  region       = local.home_region

  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  user_ocid        = var.user_ocid
}

# data "oci_containerengine_cluster_kube_config" "oke" {
#   cluster_id =  var.oke_cluster_ocid
# }

# locals {
#   cluster_endpoint       = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["server"]
#   cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["certificate-authority-data"])
#   cluster_id             = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][4]
#   cluster_region         = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][6]
# }

# # https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdownloadkubeconfigfile.htm#notes
# provider "helm" {
#   kubernetes {
#     host                   = local.cluster_endpoint
#     cluster_ca_certificate = local.cluster_ca_certificate
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["ce", "cluster", "generate-token", "--cluster-id", local.cluster_id, "--region", local.cluster_region]
#       command     = "oci"
#     }
#   }
# }
