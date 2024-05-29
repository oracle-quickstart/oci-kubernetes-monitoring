# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # OKE Cluster Metadata
  all_clusters_in_compartment = data.oci_containerengine_clusters.oke_clusters.clusters
  cluster_data                = [for c in local.all_clusters_in_compartment : c if c.id == var.oke_cluster_ocid][0]
  oke_vcn_id                  = local.cluster_data.vcn_id
  cluster_private_ip_port     = local.cluster_data.endpoints[0].private_endpoint
  cluster_private_ip          = split(":", local.cluster_private_ip_port)[0]
  cluster_private_port        = split(":", local.cluster_private_ip_port)[1]

  # RMS Private Endpoint
  use_rms_private_endpoint = var.oke_is_private && local.deploy_helm

  # Following regex checks identifies the type of resource ocid entered by stack user
  user_entered_subnet_ocid = var.oke_subnet_or_pe_ocid == null ? false : length(
  regexall("^ocid1\\.subnet\\.\\S+$", var.oke_subnet_or_pe_ocid)) > 0

  user_entered_pe_ocid = var.oke_subnet_or_pe_ocid == null ? false : length(
  regexall("^ocid1\\.ormprivateendpoint\\.\\S+$", var.oke_subnet_or_pe_ocid)) > 0

  # One of the following locals is expected to be null becuase of different regex checks
  oke_subnet_ocid = local.user_entered_subnet_ocid ? var.oke_subnet_or_pe_ocid : null
  oke_pe_ocid     = local.user_entered_pe_ocid ? var.oke_subnet_or_pe_ocid : null

  # OKE Cluster Name
  oke_metadata_name = local.cluster_data.name
  oke_cluster_name  = var.oke_cluster_name != null ? var.oke_cluster_name : local.oke_metadata_name

  # OCI LA Kubernetes Cluster Entity Name
  oke_metadata_time_created      = local.cluster_data.metadata[0].time_created # "2021-05-21 16:20:30 +0000 UTC"
  oke_time_created_rfc3398       = replace(replace(local.oke_metadata_time_created, " +0000 UTC", "Z", ), " ", "T")
  oke_metadata_is_private        = !local.cluster_data.endpoint_config[0].is_public_ip_enabled
  new_oci_la_cluster_entity_name = "${local.oke_metadata_name}_${local.oke_time_created_rfc3398}"

  # OCI User provided entity
  # Stack can set empty string
  oke_cluster_entity_ocid = var.oke_cluster_entity_ocid == "" ? null : var.oke_cluster_entity_ocid

  # IAM Controls
  create_dg_and_policy = ((var.dropdown_create_dynamicGroup_and_policies == "Create required IAM resources as part of the stack") ||
  var.opt_create_dynamicGroup_and_policies)

  ### Helm controls
  deploy_helm = var.stack_deployment_option == "Full" && !var.opt_skip_helm_chart ? true : false
  # Stack can set empty string
  helm_chart_version = var.helm_chart_version == "" ? null : var.helm_chart_version
}

# This module either create a new private endpoint or uses an existing one 
# and returns a reahable ip address to access private OKE cluster
module "rms_private_endpoint" {
  count  = local.use_rms_private_endpoint ? 1 : 0
  source = "./modules/rms_pe"

  oke_vcn_ocid          = local.oke_vcn_id
  oke_subnet_ocid       = local.oke_subnet_ocid
  private_endpoint_ocid = local.oke_pe_ocid
  private_ip_address    = local.cluster_private_ip
  pe_compartmnet_ocid   = var.oci_onm_compartment_ocid
  tags                  = var.tags
}

module "main" {
  source = "./modules/main"

  tenancy_ocid = var.tenancy_ocid
  region       = var.region

  # shared inputs
  toggle_debug             = false
  oci_onm_compartment_ocid = var.oci_onm_compartment_ocid
  oke_compartment_ocid     = var.oke_compartment_ocid
  oke_cluster_ocid         = var.oke_cluster_ocid

  # OKE
  oke_is_private = var.oke_is_private

  # tags
  tags = var.tags

  # IAM
  opt_create_dynamicGroup_and_policies = local.create_dg_and_policy

  # Dashboards
  opt_import_dashboards = var.opt_import_dashboards

  # Logan
  new_oke_entity_name                   = local.new_oci_la_cluster_entity_name
  user_provided_oke_cluster_entity_ocid = local.oke_cluster_entity_ocid

  new_logGroup_name                  = var.opt_create_new_la_logGroup ? var.oci_la_logGroup_name : null
  user_provided_oci_la_logGroup_ocid = var.opt_create_new_la_logGroup ? null : var.oci_la_logGroup_id

  # Helm
  # kubernetes_namespace                  = "oci-onm"
  install_helm_chart           = local.deploy_helm
  helmchart_version            = local.helm_chart_version
  opt_deploy_metric_server     = var.opt_deploy_metric_server
  fluentd_baseDir_path         = var.fluentd_baseDir_path
  kubernetes_cluster_id        = var.oke_cluster_ocid
  kubernetes_cluster_name      = local.oke_cluster_name
  path_to_local_onm_helm_chart = "../../../charts/oci-onm/"

  providers = {
    oci.home_region   = oci.home_region
    oci.target_region = oci.target_region
    helm              = helm
  }
}