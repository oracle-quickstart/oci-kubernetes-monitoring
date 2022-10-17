terraform {
  required_version = ">= 1.0"
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

# Update this oci provider when using terraform locally to have all other relevent fields set
# https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm
provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region       = var.region
}

# https://docs.cloud.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdownloadkubeconfigfile.htm#notes
provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = local.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["ce", "cluster", "generate-token", "--cluster-id", local.cluster_id, "--region", local.cluster_region]
      command     = "oci"
    }
  }
}


locals {
  cluster_endpoint       = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["certificate-authority-data"])
  cluster_id             = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][4]
  cluster_region         = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][6]
}