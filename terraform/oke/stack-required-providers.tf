# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 1.2.0, < 1.3.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.46"
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