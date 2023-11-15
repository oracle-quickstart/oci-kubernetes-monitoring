# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  livelab_service_account = var.livelab_switch ? module.livelab[0].service_account : ""
  fluentd_baseDir_path    = var.livelab_switch ? module.livelab[0].fluentd_baseDir_path : var.fluentd_baseDir_path

  ### helm
  # Fetch OKE cluster name from OCI OKE Service if user does not provide a name of the target cluster
  oke_cluster_name = var.oke_cluster_name == "DEFAULT" ? [for c in data.oci_containerengine_clusters.oke_clusters.clusters : c.name if c.id == var.oke_cluster_ocid][0] : var.oke_cluster_name
  deploy_helm      = var.stack_deployment_option == "Full" ? true : false

  ## Module Controls are are final verdicts on if a module should be executed or not 
  ## Module dependencies should be included here as well so a module does not run when it's depenedent moudle is disabled

  module_controls_enable_livelab_module    = alltrue([var.toggle_livelab_module, var.livelab_switch])
  module_controls_enable_dashboards_module = alltrue([var.toggle_dashboards_module])
  module_controls_enable_iam_module        = alltrue([var.toggle_iam_module, var.opt_create_dynamicGroup_and_policies, !var.livelab_switch])
  module_controls_enable_logan_module      = alltrue([var.toggle_logan_module])
  module_controls_enable_mgmt_agent_module = alltrue([var.toggle_mgmt_agent_module])
  module_controls_enable_helm_module = alltrue([var.toggle_helm_module, local.deploy_helm,
  local.module_controls_enable_mgmt_agent_module, local.module_controls_enable_logan_module])
}

// Only execute for livelab stack
// livelab module only supports local users
// it will error out when an identity domain user is used and livelab_switch is set as true
module "livelab" {
  source            = "./modules/livelab"
  current_user_ocid = var.current_user_ocid

  count = local.module_controls_enable_livelab_module ? 1 : 0

  /* providers = {
    oci = oci.home_region
  } */
}

// Import Kubernetes Dashboards
module "import_kubernetes_dashbords" {
  source           = "./modules/dashboards"
  compartment_ocid = var.oci_onm_compartment_ocid

  count = local.module_controls_enable_dashboards_module ? 1 : 0
}

// Create Required Polcies and Dynamic Group
// Needs to be called with OCI Home Region Provider
module "policy_and_dynamic-group" {
  source                   = "./modules/iam"
  root_compartment_ocid    = var.tenancy_ocid
  oci_onm_compartment_ocid = var.oci_onm_compartment_ocid
  oke_compartment_ocid     = var.oke_compartment_ocid
  oke_cluster_ocid         = var.oke_cluster_ocid

  count = local.module_controls_enable_iam_module ? 1 : 0

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

  count = local.module_controls_enable_logan_module ? 1 : 0
}

# Create a management agent key
module "management_agent" {
  source           = "./modules/mgmt_agent"
  uniquifier       = md5(var.oke_cluster_ocid)
  compartment_ocid = var.oci_onm_compartment_ocid

  count = local.module_controls_enable_mgmt_agent_module ? 1 : 0
}

// deploy oke-monitoring solution (helm release)
module "helm_release" {
  source                         = "./modules/helm"
  helm_abs_path                  = abspath("./charts/oci-onm")
  use_local_helm_chart           = var.toggle_use_local_helm_chart
  install_helm                   = var.toggle_install_helm
  generate_helm_template         = var.toggle_generate_helm_template
  oke_compartment_ocid           = var.oke_compartment_ocid
  oke_cluster_ocid               = var.oke_cluster_ocid
  kubernetes_namespace           = var.kubernetes_namespace
  oci_la_logGroup_id             = module.loggingAnalytics[0].oci_la_logGroup_ocid
  oci_la_namespace               = module.loggingAnalytics[0].oci_la_namespace
  fluentd_baseDir_path           = local.fluentd_baseDir_path
  mgmt_agent_install_key_content = module.management_agent[0].mgmt_agent_install_key_content
  opt_deploy_metric_server       = var.livelab_switch ? false : var.opt_deploy_metric_server
  deploy_mushop_config           = var.livelab_switch
  livelab_service_account        = local.livelab_service_account
  oke_cluster_name               = local.oke_cluster_name
  oke_cluster_entity_ocid        = var.oke_cluster_entity_ocid

  count = local.module_controls_enable_helm_module ? 1 : 0
}
