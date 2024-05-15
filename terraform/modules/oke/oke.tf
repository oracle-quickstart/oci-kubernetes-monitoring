locals {
  # Fetch OKE cluster name from OCI OKE Service if not provided by stack user
  all_clusters_in_compartment = data.oci_containerengine_clusters.oke_clusters.clusters
  oke_cluster_data            = [for c in local.all_clusters_in_compartment : c if c.id == var.oke_cluster_ocid][0]

  cluster_private_ip_port = var.oke_is_private ? local.oke_cluster_data.endpoints[0].private_endpoint : null
  cluster_private_ip      = var.oke_is_private ? split(":", local.cluster_private_ip_port)[0] : null
  cluster_private_port    = var.oke_is_private ? split(":", local.cluster_private_ip_port)[1] : null

  oke_cluster_name = var.oke_cluster_name == "DEFAULT" ? local.oke_cluster_data.name : var.oke_cluster_name
  oke_vcn_id       = var.oke_is_private ? local.oke_cluster_data.vcn_id : null

  # Subnet OCID or Private Endpoint OCID
  # Only one of { user_provided_subnet_ocid, user_provided_pe_ocid } locals will be set
  subnet_ocid_check         = length(regexall("ocid1\\.subnet", var.oke_subnet_or_pe_ocid)) > 0 ? true : false
  user_provided_subnet_ocid = local.subnet_ocid_check ? var.oke_subnet_or_pe_ocid : null
  user_provided_pe_ocid     = !local.subnet_ocid_check ? var.oke_subnet_or_pe_ocid : null

  create_private_endpoint = var.oke_is_private && local.subnet_ocid_check

  oke_private_endpoint_ocid = var.oke_is_private ? (local.create_private_endpoint ?
  oci_resourcemanager_private_endpoint.rms_pe[0].id : local.user_provided_pe_ocid) : null

  oke_private_rechable_ip = var.oke_is_private ? data.oci_resourcemanager_private_endpoint_reachable_ip.rms_pe[0].ip_address : null

  helm_provider_config = {
    host = (var.oke_is_private ?
      "https://${local.oke_private_rechable_ip}:${local.cluster_private_port}" :
    yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["clusters"][0]["cluster"]["server"])
    cluster_ca_certificate = var.oke_is_private ? null : base64decode(yamldecode(
      data.oci_containerengine_cluster_kube_config.oke.content)
    ["clusters"][0]["cluster"]["certificate-authority-data"])
    cluster_id     = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][4]
    cluster_region = yamldecode(data.oci_containerengine_cluster_kube_config.oke.content)["users"][0]["user"]["exec"]["args"][6]
    insecure       = var.oke_is_private
  }
}

data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = var.oke_cluster_ocid
}

data "oci_containerengine_clusters" "oke_clusters" {
  compartment_id = var.oke_compartment_ocid
}

data "oci_resourcemanager_private_endpoint_reachable_ip" "rms_pe" {
  count               = var.oke_is_private ? 1 : 0
  private_endpoint_id = local.oke_private_endpoint_ocid
  private_ip          = local.cluster_private_ip
}

resource "oci_resourcemanager_private_endpoint" "rms_pe" {
  count          = local.create_private_endpoint ? 1 : 0
  compartment_id = var.oci_onm_compartment_ocid
  display_name   = "OKE - ${local.oke_cluster_name}"
  vcn_id         = local.oke_vcn_id
  subnet_id      = local.user_provided_subnet_ocid
}