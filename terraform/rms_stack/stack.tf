# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # OKE Cluster Metadata
  all_clusters_in_compartment = data.oci_containerengine_clusters.oke_clusters.clusters
  cluster_data                = [for c in local.all_clusters_in_compartment : c if c.id == var.oke_cluster_ocid][0]

  # OKE Cluster Name
  oke_metadata_name = local.cluster_data.name
  oke_cluster_name  = var.oke_cluster_name != null ? var.oke_cluster_name : local.oke_metadata_name

  # OCI LA Kubernetes Cluster Entity Name
  oke_metadata_time_created      = local.cluster_data.metadata[0].time_created # "2021-05-21 16:20:30 +0000 UTC"
  oke_time_created_rfc3398       = replace(replace(local.oke_metadata_time_created, " +0000 UTC", "Z", ), " ", "T")
  oke_metadata_is_private        = !local.cluster_data.endpoint_config[0].is_public_ip_enabled
  new_oci_la_cluster_entity_name = "${local.oke_metadata_name}_${local.oke_time_created_rfc3398}"

  # IAM Controls
  create_dg_and_policy = (var.dropdown_create_dynamicGroup_and_policies == "Create" ||
  var.opt_create_dynamicGroup_and_policies ? true : false)

  ### Helm controls
  deploy_helm        = var.stack_deployment_option == "Full" && var.opt_deploy_helm_chart ? true : false
  helm_chart_version = var.helm_chart_version == "null" ? null : var.helm_chart_version
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
  new_oke_entity_name                   = var.opt_create_new_la_entity ? local.new_oci_la_cluster_entity_name : null
  user_provided_oke_cluster_entity_ocid = var.opt_create_new_la_entity ? null : var.oke_cluster_entity_ocid

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
    oci.home_region = oci.home_region
    oci             = oci.target_region
    helm            = helm
  }
}