# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # Fetch OKE cluster name from OCI OKE Service if not provided by stack user
  all_clusters_in_compartment = data.oci_containerengine_clusters.oke_clusters.clusters
  cluster_data                = [for c in local.all_clusters_in_compartment : c if c.id == var.oke_cluster_ocid][0]

  oke_cluster_name = local.cluster_data.name
  oke_time_created = local.cluster_data.metadata[0].time_created # "2021-05-21 16:20:30 +0000 UTC"
  oke_is_private   = !local.cluster_data.endpoint_config[0].is_public_ip_enabled
  # private_endpoint = local.is_private ? local.cluster_data.endpoints[0].private_endpoint : null

  #   fluentd_baseDir_path = 

  #   ### helm
  #   # Fetch OKE cluster name from OCI OKE Service if user does not provide a name of the target cluster
  #   deploy_helm = var.stack_deployment_option == "Full" && var.opt_deploy_helm_chart ? true : false

  #   oke_time_created         = module.oke.metadata_time_created
  #   oke_time_created_rfc3398 = replace(replace(local.oke_time_created, " +0000 UTC", "Z", ), " ", "T")
  #   new_entity_name          = "${module.oke.metadata_name}_${local.oke_time_created_rfc3398}"
  #   create_oke_entity        = var.opt_create_new_la_entity_if_not_provided && var.oke_cluster_entity_ocid == "DEFAULT"

  local_helm_path = var.path_to_local_onm_helm_chart == null ? null : abspath(var.path_to_local_onm_helm_chart)

  oke_entity_ocid = (var.user_provided_oke_cluster_entity_ocid == null ? module.logan.oke_cluster_entity_ocid :
  var.user_provided_oke_cluster_entity_ocid)

  logGroup_ocid = (var.user_provided_oci_la_logGroup_ocid == null ?
  module.logan[0].new_la_logGroup_ocid : var.user_provided_oci_la_logGroup_ocid)

  new_logGroup_name   = var.user_provided_oci_la_logGroup_ocid == null ? var.new_logGroup_name : null
  new_oke_entity_name = var.user_provided_oke_cluster_entity_ocid == null ? var.new_oke_entity_name : null
  #   helmchart_version = var.helmchart_version == "latest" ? null : var.helmchart_version

  #   ## Module Controls are are final verdicts on if a module should be executed or not 
  #   ## Module dependencies should be included here as well so a module does not run when it's depenedent moudle is disabled

  module_controls_enable_iam_module        = alltrue([var.toggle_iam_module, var.opt_create_dynamicGroup_and_policies])
  module_controls_enable_logan_module      = alltrue([var.toggle_logan_module])
  module_controls_enable_mgmt_agent_module = alltrue([var.toggle_mgmt_agent_module])
  module_controls_enable_helm_module       = alltrue([var.toggle_helm_module, local.module_controls_enable_mgmt_agent_module, local.module_controls_enable_logan_module])
  module_controls_enable_dashboards_module = alltrue([var.toggle_dashboards_module, var.opt_import_dashboards])
}

data "oci_containerengine_clusters" "oke_clusters" {
  compartment_id = var.oke_compartment_ocid
}

// Fetch OKE Metadata and kubeconfig
# module "oke" {
#   source               = "../oke"
#   oke_cluster_ocid     = var.oke_cluster_ocid
#   oke_compartment_ocid = var.oke_compartment_ocid
#   debug                = var.toggle_debug
# }

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

  depends_on = [null_resource.validate_inputs]
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
  debug               = var.toggle_debug
  tags                = var.tags

  depends_on = [null_resource.validate_inputs]
}

# Create a management agent key
module "management_agent" {
  source = "../mgmt_agent"
  count  = local.module_controls_enable_mgmt_agent_module ? 1 : 0

  uniquifier       = md5(var.oke_cluster_ocid)
  compartment_ocid = var.oci_onm_compartment_ocid
  debug            = var.toggle_debug

  depends_on = [null_resource.validate_inputs]
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
  oke_compartment_ocid           = var.oke_compartment_ocid
  oke_cluster_ocid               = var.oke_cluster_ocid
  kubernetes_namespace           = var.kubernetes_namespace
  oci_la_logGroup_id             = local.logGroup_ocid
  oci_la_namespace               = module.logan[0].oci_la_namespace
  fluentd_baseDir_path           = var.fluentd_baseDir_path
  mgmt_agent_install_key_content = module.management_agent[0].mgmt_agent_install_key_content
  opt_deploy_metric_server       = var.opt_deploy_metric_server
  oke_cluster_name               = local.oke_cluster_name
  oke_cluster_entity_ocid        = local.oke_entity_ocid
  # livelab_service_account        = local.livelab_service_account

  depends_on = [null_resource.validate_inputs]
}

// Import Kubernetes Dashboards
module "import_kubernetes_dashbords" {
  source = "../dashboards"
  count  = local.module_controls_enable_dashboards_module ? 1 : 0

  compartment_ocid = var.oci_onm_compartment_ocid
  debug            = var.toggle_debug
  tags             = var.tags

  depends_on = [null_resource.validate_inputs, module.helm_release]
}

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