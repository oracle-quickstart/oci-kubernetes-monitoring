# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  ## livelab
  oci_username            = data.oci_identity_user.livelab_user.name
  livelab_service_account = local.oci_username

  ## Helm release
  fluentd_baseDir_path = var.livelab_switch ? "/var/log/${local.oci_username}" : var.fluentd_baseDir_path

  ## Deployment options
  deployment_options = {
    enable_helm_module = var.enable_helm_module && length(regexall("^Full:", var.stack_deployment_option)) > 0
  }
}

// Import Kubernetes Dashboards
module "import_kubernetes_dashbords" {
  source           = "./modules/dashboards"
  compartment_ocid = var.oci_onm_compartment_ocid

  count = var.enable_dashboard_module ? 1 : 0
}

// Create Required Polcies and Dynamic Group
// Needs to be called with OCI Home Region Provider
module "policy_and_dynamic-group" {
  source                   = "./modules/iam"
  root_compartment_ocid    = var.tenancy_ocid
  oci_onm_compartment_ocid = var.oci_onm_compartment_ocid
  oke_compartment_ocid     = var.oke_compartment_ocid
  oke_cluster_ocid         = var.oke_cluster_ocid

  count = var.opt_create_dynamicGroup_and_policies && !var.livelab_switch ? 1 : 0

  providers = {
    oci = oci.home_region
  }
}

// Create Logging Analytics Resorces
module "loggingAnalytics" {
  source               = "./modules/logan"
  tenancy_ocid         = var.tenancy_ocid
  create_new_logGroup  = var.opt_create_new_la_logGroup
  new_logGroup_name    = var.oci_la_logGroup_name
  compartment_ocid     = var.oci_onm_compartment_ocid
  existing_logGroup_id = var.oci_la_logGroup_id
}

// deploy oke-monitoring solution (helm release)
module "helm_release" {
  source                 = "./modules/helm"
  helm_abs_path          = abspath("./charts/oci-onm")
  generate_helm_template = var.generate_helm_template

  oke_compartment_ocid = var.oke_compartment_ocid
  oke_cluster_ocid     = var.oke_cluster_ocid

  logan_container_image_url = var.logan_container_image_url
  kubernetes_namespace      = var.kubernetes_namespace

  oci_la_logGroup_id   = module.loggingAnalytics.oci_la_logGroup_ocid
  oci_la_namespace     = module.loggingAnalytics.oci_la_namespace
  fluentd_baseDir_path = local.fluentd_baseDir_path

  mgmt_agent_compartment_ocid    = var.oci_onm_compartment_ocid
  mgmt_agent_container_image_url = var.mgmt_agent_container_image_url
  opt_deploy_metric_server       = var.livelab_switch ? true : var.opt_deploy_metric_server

  deploy_mushop_config    = var.livelab_switch
  livelab_service_account = local.livelab_service_account

  count = local.deployment_options.enable_helm_module ? 1 : 0
}
