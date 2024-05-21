# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # OCI Provider config
  home_region_key = data.oci_identity_tenancy.tenant_details.home_region_key
  home_region     = [for r in data.oci_identity_regions.region_map.regions : r.name if r.key == local.home_region_key][0]

  ### RMS private endpoint
  # Subnet OCID or Private Endpoint OCID
  # Only one of { user_provided_subnet_ocid, user_provided_pe_ocid } locals will be set
  oke_subnet_or_pe_ocid = var.oke_subnet_or_pe_ocid

  oke_vcn_id              = local.cluster_data.vcn_id
  cluster_private_ip_port = local.cluster_data.endpoints[0].private_endpoint
  cluster_private_ip      = split(":", local.cluster_private_ip_port)[0]
  cluster_private_port    = split(":", local.cluster_private_ip_port)[1]

  use_private_endpoint    = local.oke_subnet_or_pe_ocid != null && local.deploy_helm
  create_private_endpoint = local.use_private_endpoint && local.user_entered_subnet_ocid

  user_entered_subnet_ocid = length(regexall("ocid1\\.subnet", local.oke_subnet_or_pe_ocid)) > 0 ? true : false

  oke_private_endpoint_ocid = local.create_private_endpoint ? oci_resourcemanager_private_endpoint.rms_pe[0].id : local.oke_subnet_or_pe_ocid
  oke_private_rechable_ip   = local.use_private_endpoint ? data.oci_resourcemanager_private_endpoint_reachable_ip.rms_pe[0].ip_address : null

  # Helm provider config

  oke_host = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["server"]
  oke_cert = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["certificate-authority-data"])

  # used to configure helm provider
  kube_config = {
    host                   = local.use_private_endpoint ? "https://${local.oke_private_rechable_ip}:${local.cluster_private_port}" : local.oke_host
    cluster_ca_certificate = local.use_private_endpoint ? null : local.oke_cert
    cluster_id             = var.oke_cluster_ocid #yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][4]
    cluster_region         = var.region           #yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][6]
    insecure               = local.use_private_endpoint
  }
}

resource "oci_resourcemanager_private_endpoint" "rms_pe" {
  count          = local.create_private_endpoint ? 1 : 0
  compartment_id = var.oci_onm_compartment_ocid
  display_name   = "OKE - ${local.oke_cluster_name}"
  vcn_id         = local.oke_vcn_id
  subnet_id      = local.oke_subnet_or_pe_ocid

  #tags
  defined_tags  = var.tags.definedTags
  freeform_tags = var.tags.freeformTags

  # depends_on = [null_resource.validate_stack_inputs]
}

data "oci_resourcemanager_private_endpoint_reachable_ip" "rms_pe" {
  count               = local.use_private_endpoint ? 1 : 0
  private_endpoint_id = local.oke_private_endpoint_ocid
  private_ip          = local.cluster_private_ip

  # depends_on = [null_resource.validate_stack_inputs]
}

data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "region_map" {
}

data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = var.oke_cluster_ocid
}

data "oci_containerengine_clusters" "oke_clusters" {
  compartment_id = var.oke_compartment_ocid
}


provider "oci" {
  alias            = "target_region"
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
      api_version = "client.authentication.k8s.io/v1beta1" # TODO check
      args = ["ce", "cluster", "generate-token", "--cluster-id",
      local.kube_config.cluster_id, "--region", local.kube_config.cluster_region]
      command = "oci"
    }
    insecure = local.kube_config.insecure
  }
}