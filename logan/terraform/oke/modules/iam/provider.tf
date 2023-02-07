terraform {
  required_version = ">= 1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.96.0"
      # https://registry.terraform.io/providers/hashicorp/oci/4.85.0
    }
  }
}