# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  local_helm_path = var.path_to_local_onm_helm_chart != null && var.toggle_use_local_helm_chart ? abspath(var.path_to_local_onm_helm_chart) : null

  # Log Group Display Name
  default_log_group_display_name = local.new_oke_entity_name
  log_group_display_name         = var.log_group_name != null ? var.log_group_name : local.default_log_group_display_name

  # OKE Metadata
  all_clusters_in_compartment = data.oci_containerengine_clusters.oke_clusters.clusters
  cluster_data                = [for c in local.all_clusters_in_compartment : c if c.id == var.oke_cluster_ocid][0]

  # OCI LA Kubernetes Cluster Entity Name
  # OKE always responds with same time format string in UTC regardless or realm or region [Validated with OKE Team]
  oke_metadata_time_created = local.cluster_data.metadata[0].time_created                                      # "2021-05-21 16:20:30 +0000 UTC"
  oke_time_created_rfc3398  = replace(replace(local.oke_metadata_time_created, " +0000 UTC", "Z", ), " ", "T") #"2021-05-21T16:20:30Z"
  oke_metadata_is_private   = !local.cluster_data.endpoint_config[0].is_public_ip_enabled
  oke_name                  = local.cluster_data.name
  new_oke_entity_name       = "${local.oke_name}_${local.oke_time_created_rfc3398}"
  k8s_version               = local.cluster_data.kubernetes_version

  entity_metadata_list = [
    { name : "cluster", value : local.new_oke_entity_name, type : "k8s_solution" },
    { name : "cluster_name", value : local.oke_name, type : "k8s_solution" },
    { name : "cluster_date", value : local.oke_time_created_rfc3398, type : "k8s_solution" },
    { name : "cluster_ocid", value : var.oke_cluster_ocid, type : "k8s_solution" },
    { name : "solution_type", value : "OKE", type : "k8s_solution" },
    { name : "k8s_version", value : local.k8s_version, type : "k8s_solution" },
    { name : "metrics_namespace", value : "mgmtagent_kubernetes_metrics", type : "k8s_solution" },
    { name : "onm_compartment", value : var.oci_onm_compartment_ocid, type : "k8s_solution" },
    { name : "deployment_status", value : "UNKNOWN", type : "k8s_solution" },
    { name : "deployment_stack_ocid", value : "UNKNOWN", type : "k8s_solution" }
  ]

  # OKE Cluster Name in Helm
  oke_cluster_name_in_helm = var.kubernetes_cluster_name == null ? local.new_oke_entity_name : var.kubernetes_cluster_name

  # Module Controls are are final verdicts on if a module should be executed or not 
  # Module dependencies should be included here as well so a module does not run when it's dependent module is disabled

  module_controls_enable_iam_module        = alltrue([var.toggle_iam_module, var.opt_create_dynamicGroup_and_policies])
  module_controls_enable_logan_module      = alltrue([var.toggle_logan_module])
  module_controls_enable_mgmt_agent_module = alltrue([var.toggle_mgmt_agent_module])
  module_controls_enable_helm_module       = alltrue([var.toggle_helm_module, local.module_controls_enable_mgmt_agent_module, local.module_controls_enable_logan_module])
  module_controls_enable_dashboards_module = alltrue([var.toggle_dashboards_module, var.opt_import_dashboards])
}

# We are querying all clusters in the compartment cause
# OKE service does not support data resource for specific OKE Cluster
data "oci_containerengine_clusters" "oke_clusters" {
  compartment_id = var.oke_compartment_ocid
}

# Create Required Policies and Dynamic Group
# Needs to be called with OCI Home Region Provider
module "iam" {
  source = "../iam"
  count  = local.module_controls_enable_iam_module ? 1 : 0

  root_compartment_ocid             = var.tenancy_ocid
  oci_onm_compartment_ocid          = var.oci_onm_compartment_ocid
  oke_compartment_ocid              = var.oke_compartment_ocid
  oke_cluster_ocid                  = var.oke_cluster_ocid
  create_service_discovery_policies = var.enable_service_log
  oci_la_log_group_ocid             = module.logan[0].log_group_ocid
  tags                              = var.tags

  providers = {
    oci = oci.home_region
  }
}

# Create Logging Analytics Resources
module "logan" {
  source = "../logan"
  count  = local.module_controls_enable_logan_module ? 1 : 0

  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
  compartment_ocid = var.oci_onm_compartment_ocid

  new_entity_name      = local.new_oke_entity_name
  entity_metadata_list = local.entity_metadata_list
  oke_entity_ocid      = var.oke_cluster_entity_ocid

  opt_create_new_la_log_group = var.opt_create_new_la_log_group
  log_group_ocid              = var.log_group_ocid
  log_group_display_name      = local.log_group_display_name

  debug = var.debug
  tags  = var.tags
}

# Create a management agent key
module "management_agent" {
  source = "../mgmt_agent"
  count  = local.module_controls_enable_mgmt_agent_module ? 1 : 0

  uniquifier       = md5(var.oke_cluster_ocid)
  compartment_ocid = var.oci_onm_compartment_ocid
  tags             = var.tags
  debug            = var.debug
}

# deploy oke-monitoring solution (helm release)
module "helm_release" {
  source = "../helm"
  count  = local.module_controls_enable_helm_module ? 1 : 0

  # module controls
  install_helm_chart     = var.install_helm_chart && var.toggle_install_helm
  generate_helm_template = var.toggle_generate_helm_template
  debug                  = var.debug

  # helm command
  local_helm_chart   = local.local_helm_path
  helm_chart_version = var.helm_chart_version

  # values.yaml
  kubernetes_cluster_id          = var.kubernetes_cluster_id
  kubernetes_cluster_name        = local.oke_cluster_name_in_helm
  kubernetes_namespace           = var.kubernetes_namespace
  oci_la_log_group_ocid          = module.logan[0].log_group_ocid
  oci_la_namespace               = module.logan[0].oci_la_namespace
  oci_la_cluster_entity_ocid     = module.logan[0].oke_entity_ocid
  mgmt_agent_install_key_content = module.management_agent[0].mgmt_agent_install_key_content
  opt_deploy_metric_server       = var.opt_deploy_metric_server
  fluentd_base_dir_path          = var.fluentd_base_dir_path
  oci_domain                     = var.oci_domain
  enable_service_log             = var.enable_service_log
  LOGAN_ENDPOINT                 = var.LOGAN_ENDPOINT
  tags                           = var.tags
}

# Import Kubernetes Dashboards
module "import_kubernetes_dashboards" {
  source = "../dashboards"
  count  = local.module_controls_enable_dashboards_module ? 1 : 0

  compartment_ocid = var.oci_onm_compartment_ocid
  debug            = var.debug
  tags             = var.tags
}
