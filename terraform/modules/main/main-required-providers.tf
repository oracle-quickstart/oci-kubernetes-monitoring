# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 1.2"
  required_providers {
    oci = {
      source                = "oracle/oci"
      version               = "~> 5.46"
      configuration_aliases = [oci, oci.home_region]
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
  }
}