# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # Resolve Null string --> "" inputs
  oke_cluster_entity_ocid = var.oke_cluster_entity_ocid == "" ? null : var.oke_cluster_entity_ocid
  helm_chart_version      = var.helm_chart_version == "" ? null : var.helm_chart_version
  oci_la_logGroup_name    = var.oci_la_logGroup_name == "" ? null : var.oci_la_logGroup_name

  # RMS Private Endpoint
  use_rms_private_endpoint = var.connect_via_private_endpoint && local.deploy_helm

  # Following regex checks identifies the type of resource ocid entered by stack user
  user_entered_subnet_ocid = var.oke_subnet_or_pe_ocid == null ? false : length(
  regexall("^ocid1\\.subnet\\.\\S+$", var.oke_subnet_or_pe_ocid)) > 0

  user_entered_pe_ocid = var.oke_subnet_or_pe_ocid == null ? false : length(
  regexall("^ocid1\\.ormprivateendpoint\\.\\S+$", var.oke_subnet_or_pe_ocid)) > 0

  # One of the following locals is expected to be null becuase of different regex checks
  oke_subnet_ocid = local.user_entered_subnet_ocid ? var.oke_subnet_or_pe_ocid : null
  oke_pe_ocid     = local.user_entered_pe_ocid ? var.oke_subnet_or_pe_ocid : null

  # IAM Controls
  create_dg_and_policy = var.dropdown_create_dynamicGroup_and_policies == "Create required IAM resources as part of the stack"

  # Helm controls
  deploy_helm = var.stack_deployment_option == "Full" ? true : false
}

# Create a new private endpoint or uses an existing one 
# Returns a reahable ip address to access private OKE cluster
module "rms_private_endpoint" {
  count  = local.use_rms_private_endpoint ? 1 : 0
  source = "./modules/rms_pe"

  oke_subnet_ocid       = local.oke_subnet_ocid
  private_endpoint_ocid = local.oke_pe_ocid
  private_ip_address    = local.cluster_private_ip
  pe_compartmnet_ocid   = var.oci_onm_compartment_ocid
  oke_compartment_ocid  = var.oke_compartment_ocid
  oke_cluster_ocid      = var.oke_cluster_ocid

  tags  = var.tags
  debug = false
}

# Create OCI resources for the helm chart
# Deploys oci-onm helm chart in target cluster
module "main" {
  source = "./modules/main"

  tenancy_ocid = var.tenancy_ocid
  region       = var.region

  # shared inputs
  # debug                    = var.debug # Do not allow debug mode from stack input
  oci_onm_compartment_ocid = var.oci_onm_compartment_ocid
  oke_compartment_ocid     = var.oke_compartment_ocid
  oke_cluster_ocid         = var.oke_cluster_ocid

  # tags
  tags = var.tags

  # IAM
  opt_create_dynamicGroup_and_policies = local.create_dg_and_policy

  # Dashboards
  opt_import_dashboards = var.opt_import_dashboards

  # Logan
  user_provided_oke_cluster_entity_ocid = local.oke_cluster_entity_ocid
  new_logGroup_name                     = var.opt_create_new_la_logGroup ? local.oci_la_logGroup_name : null
  user_provided_oci_la_logGroup_ocid    = var.opt_create_new_la_logGroup ? null : var.oci_la_logGroup_id

  # Helm
  # kubernetes_namespace                  = "oci-onm"
  install_helm_chart           = local.deploy_helm
  helmchart_version            = local.helm_chart_version
  opt_deploy_metric_server     = var.opt_deploy_metric_server
  fluentd_baseDir_path         = var.fluentd_baseDir_path
  kubernetes_cluster_id        = var.oke_cluster_ocid
  kubernetes_cluster_name      = var.oke_cluster_name
  path_to_local_onm_helm_chart = "../../../charts/oci-onm/"

  providers = {
    oci.home_region   = oci.home_region
    oci.target_region = oci.target_region
    helm              = helm
  }
}