# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  local_helm_path = var.path_to_local_onm_helm_chart != null && var.toggle_use_local_helm_chart ? abspath(var.path_to_local_onm_helm_chart) : null

  new_logGroup_name   = var.user_provided_oci_la_logGroup_ocid == null ? var.new_logGroup_name : null
  new_oke_entity_name = var.user_provided_oke_cluster_entity_ocid == null ? var.new_oke_entity_name : null

  #   ## Module Controls are are final verdicts on if a module should be executed or not 
  #   ## Module dependencies should be included here as well so a module does not run when it's depenedent moudle is disabled

  module_controls_enable_iam_module        = alltrue([var.toggle_iam_module, var.opt_create_dynamicGroup_and_policies])
  module_controls_enable_logan_module      = alltrue([var.toggle_logan_module])
  module_controls_enable_mgmt_agent_module = alltrue([var.toggle_mgmt_agent_module])
  module_controls_enable_helm_module       = alltrue([var.toggle_helm_module, local.module_controls_enable_mgmt_agent_module, local.module_controls_enable_logan_module])
  module_controls_enable_dashboards_module = alltrue([var.toggle_dashboards_module, var.opt_import_dashboards])
}

// Create Required Policies and Dynamic Group
// Needs to be called with OCI Home Region Provider
module "iam" {
  source = "../iam"
  count  = local.module_controls_enable_iam_module ? 1 : 0

  root_compartment_ocid    = var.tenancy_ocid
  oci_onm_compartment_ocid = var.oci_onm_compartment_ocid
  oke_compartment_ocid     = var.oke_compartment_ocid
  oke_cluster_ocid         = var.oke_cluster_ocid
  tags                     = var.tags

  providers = {
    oci = oci.home_region
  }
}

# Create Logging Analytics Resorces
module "logan" {
  source = "../logan"
  count  = local.module_controls_enable_logan_module ? 1 : 0

  tenancy_ocid        = var.tenancy_ocid
  region              = var.region
  compartment_ocid    = var.oci_onm_compartment_ocid
  new_logGroup_name   = local.new_logGroup_name
  new_oke_entity_name = local.new_oke_entity_name
  entity_ocid         = var.user_provided_oke_cluster_entity_ocid
  logGroup_ocid       = var.user_provided_oci_la_logGroup_ocid

  debug = var.toggle_debug
  tags  = var.tags

  providers = {
    oci = oci.target_region
  }
}

# Create a management agent key
module "management_agent" {
  source = "../mgmt_agent"
  count  = local.module_controls_enable_mgmt_agent_module ? 1 : 0

  uniquifier       = md5(var.oke_cluster_ocid)
  compartment_ocid = var.oci_onm_compartment_ocid
  debug            = var.toggle_debug

  providers = {
    oci = oci.target_region
  }
}

// deploy oke-monitoring solution (helm release)
module "helm_release" {
  source = "../helm"
  count  = local.module_controls_enable_helm_module ? 1 : 0

  # module controls
  install_helm_chart     = var.install_helm_chart && var.toggle_install_helm
  generate_helm_template = var.toggle_generate_helm_template
  debug                  = var.toggle_debug

  deploy_mushop_config = false #var.livelab_switch

  # helm command
  local_helm_chart  = local.local_helm_path
  helmchart_version = var.helmchart_version

  # values.yaml
  kubernetes_cluster_id          = var.kubernetes_cluster_id
  kubernetes_cluster_name        = var.kubernetes_cluster_name
  kubernetes_namespace           = var.kubernetes_namespace
  oci_la_logGroup_ocid           = module.logan[0].logGroup_ocid
  oci_la_namespace               = module.logan[0].oci_la_namespace
  oci_la_cluster_entity_ocid     = module.logan[0].oke_entity_ocid
  mgmt_agent_install_key_content = module.management_agent[0].mgmt_agent_install_key_content
  opt_deploy_metric_server       = var.opt_deploy_metric_server
  fluentd_baseDir_path           = var.fluentd_baseDir_path
  # livelab_service_account        = local.livelab_service_account

  providers = {
    helm = helm
  }
}

// Import Kubernetes Dashboards
module "import_kubernetes_dashbords" {
  source = "../dashboards"
  count  = local.module_controls_enable_dashboards_module ? 1 : 0

  compartment_ocid = var.oci_onm_compartment_ocid
  debug            = var.toggle_debug
  tags             = var.tags

  providers = {
    oci = oci.target_region
  }
}

// Fetch OKE Metadata and kubeconfig
# module "oke" {
#   source               = "../oke"
#   oke_cluster_ocid     = var.oke_cluster_ocid
#   oke_compartment_ocid = var.oke_compartment_ocid
#   debug                = var.toggle_debug
# }

# // Only execute for livelab stack
# // livelab module only supports local users
# // it will error out when an identity domain user is used and livelab_switch is set as true
# module "livelab" {
#   source            = "./modules/livelab"
#   current_user_ocid = var.current_user_ocid
#   debug             = var.toggle_debug

#   count = local.module_controls_enable_livelab_module ? 1 : 0

#   /* providers = {
#     oci = oci.home_region
#   } */
# }