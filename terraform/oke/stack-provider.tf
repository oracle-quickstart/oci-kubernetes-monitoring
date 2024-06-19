# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 1.2.0, < 1.3.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.44.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}