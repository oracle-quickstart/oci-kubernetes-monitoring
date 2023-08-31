# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  livelab_service_account = var.livelab_switch ? module.livelab[0].service_account : ""
  fluentd_baseDir_path    = var.livelab_switch ? module.livelab[0].fluentd_baseDir_path : var.fluentd_baseDir_path

  oke_cluster_name = [for c in data.oci_containerengine_clusters.oke_clusters.clusters : c.name if c.id == var.oke_cluster_ocid][0]

  deploy_helm_ui_option = var.stack_deployment_option == "Full" ? true : false

  ## Module Controls evalues developer options and UI inputs/options (ex - stack_deployment_option) to determine
  ## if a module should be executed
  module_controls = {
    enable_livelab_module    = alltrue([var.dev_switch_livelab_module, var.livelab_switch])
    enable_dashboards_module = alltrue([var.dev_switch_dashboards_module])
    enable_iam_module        = alltrue([var.dev_switch_iam_module, var.opt_create_dynamicGroup_and_policies, !var.livelab_switch])
    enable_logan_module      = alltrue([var.dev_switch_logan_module])
    enable_mgmt_agent_module = alltrue([var.dev_switch_mgmt_agent_module])
    enable_helm_module       = alltrue([var.dev_switch_helm_module, local.deploy_helm_ui_option])
  }
}

// Only execute for livelab stack
// livelab module only supports local users
// it will error out when an identity domain user is used and livelab_switch is set as true
module "livelab" {
  source            = "./modules/livelab"
  current_user_ocid = var.current_user_ocid

  count = local.module_controls.enable_livelab_module ? 1 : 0

  /* providers = {
    oci = oci.home_region
  } */
}

// Import Kubernetes Dashboards
module "import_kubernetes_dashbords" {
  source           = "./modules/dashboards"
  compartment_ocid = var.oci_onm_compartment_ocid

  count = local.module_controls.enable_dashboards_module ? 1 : 0
}

// Create Required Polcies and Dynamic Group
// Needs to be called with OCI Home Region Provider
module "policy_and_dynamic-group" {
  source                   = "./modules/iam"
  root_compartment_ocid    = var.tenancy_ocid
  oci_onm_compartment_ocid = var.oci_onm_compartment_ocid
  oke_compartment_ocid     = var.oke_compartment_ocid
  oke_cluster_ocid         = var.oke_cluster_ocid

  count = local.module_controls.enable_iam_module ? 1 : 0

  providers = {
    oci = oci.home_region
  }
}

// Create Logging Analytics Resorces
module "loggingAnalytics" {
  source                     = "./modules/logan"
  tenancy_ocid               = var.tenancy_ocid
  create_new_logGroup        = var.opt_create_new_la_logGroup
  new_logGroup_name          = var.oci_la_logGroup_name
  compartment_ocid           = var.oci_onm_compartment_ocid
  existing_logGroup_id       = var.oci_la_logGroup_id

  count = local.module_controls.enable_logan_module ? 1 : 0
}

# Create a management agent key
module "management_agent" {
  source           = "./modules/mgmt_agent"
  uniquifier       = md5(var.oke_cluster_ocid)
  compartment_ocid = var.oci_onm_compartment_ocid

  count = local.module_controls.enable_mgmt_agent_module ? 1 : 0
}

// deploy oke-monitoring solution (helm release)
module "helm_release" {
  source                         = "./modules/helm"
  helm_abs_path                  = abspath("./charts/oci-onm")
  use_local_helm_chart           = var.dev_switch_use_local_helm_chart
  generate_helm_template         = var.dev_switch_generate_helm_template
  oke_compartment_ocid           = var.oke_compartment_ocid
  oke_cluster_ocid               = var.oke_cluster_ocid
  logan_container_image_url      = var.logan_container_image_url
  kubernetes_namespace           = var.kubernetes_namespace
  oci_la_logGroup_id             = module.loggingAnalytics[0].oci_la_logGroup_ocid
  oci_la_namespace               = module.loggingAnalytics[0].oci_la_namespace
  fluentd_baseDir_path           = local.fluentd_baseDir_path
  mgmt_agent_install_key_content = module.management_agent[0].mgmt_agent_install_key_content
  mgmt_agent_container_image_url = var.mgmt_agent_container_image_url
  opt_deploy_metric_server       = var.livelab_switch ? true : var.opt_deploy_metric_server
  deploy_mushop_config           = var.livelab_switch
  livelab_service_account        = local.livelab_service_account

  count = local.module_controls.enable_helm_module ? 1 : 0
}
