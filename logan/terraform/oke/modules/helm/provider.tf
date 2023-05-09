# # # Copyright (c) 2023, Oracle and/or its affiliates.
# # # Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.
# #
# # Copyright (c) 2023, Oracle and/or its affiliates.
# # Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# # Copyright (c) 2023, Oracle and/or its affiliates.
# # Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# # Copyright (c) 2023, Oracle and/or its affiliates.
# # Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 1.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
      # https://registry.terraform.io/providers/hashicorp/helm/2.1.0
    }
  }
}

data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = var.oke_cluster_ocid
  count      = var.enable_helm_release ? 1 : 0
}

locals {
  // following locals are set as "place-holder" when user opts out of helm release
  cluster_endpoint       = var.enable_helm_release ? yamldecode(data.oci_containerengine_cluster_kube_config.oke[0].content)["clusters"][0]["cluster"]["server"] : "place-holder"
  cluster_ca_certificate = var.enable_helm_release ? base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke[0].content)["clusters"][0]["cluster"]["certificate-authority-data"]) : "place-holder"
  cluster_id             = var.enable_helm_release ? yamldecode(data.oci_containerengine_cluster_kube_config.oke[0].content)["users"][0]["user"]["exec"]["args"][4] : "place-holder"
  cluster_region         = var.enable_helm_release ? yamldecode(data.oci_containerengine_cluster_kube_config.oke[0].content)["users"][0]["user"]["exec"]["args"][6] : "place-holder"
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
