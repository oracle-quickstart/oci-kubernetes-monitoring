terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.7"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12.1"
    }
  }
}

provider "oci" {
  # Documentation: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm

  # Instance Principal Authorization
  region = var.oci_region

  # Config file based authentication
  tenancy_ocid = var.oci_tenancy_ocid
  user_ocid    = var.oci_user_ocid
  private_key  = var.private_key_path
  fingerprint  = var.fingerprint
}

provider "external" {
}

# provider "time" {
# }