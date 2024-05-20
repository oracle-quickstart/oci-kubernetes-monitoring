# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  # livelab_service_account = var.livelab_switch ? module.livelab[0].service_account : ""
  # fluentd_baseDir_path    = var.livelab_switch ? module.livelab[0].fluentd_baseDir_path : var.fluentd_baseDir_path 

  ### helm
  # Fetch OKE cluster name from OCI OKE Service if user does not provide a name of the target cluster
  deploy_helm = var.stack_deployment_option == "Full" && var.opt_deploy_helm_chart ? true : false

  # oke_time_created         = module.oke.metadata_time_created
  # oke_time_created_rfc3398 = replace(replace(local.oke_time_created, " +0000 UTC", "Z", ), " ", "T")
  # new_entity_name          = "${module.oke.metadata_name}_${local.oke_time_created_rfc3398}"
  # create_oke_entity        = var.opt_create_new_la_entity_if_not_provided && var.oke_cluster_entity_ocid == "DEFAULT"

  # oke_entity_ocid = local.create_oke_entity ? module.loggingAnalytics[0].oke_cluster_entity_ocid : var.oke_cluster_entity_ocid

  helmchart_version = var.helmchart_version == "latest" ? null : var.helmchart_version
}

module "main" {
  source = "./modules/main"

  tenancy_ocid = var.tenancy_ocid
  region       = var.region

  # shared inputs
  oci_onm_compartment_ocid = var.oci_onm_compartment_ocid
  oke_compartment_ocid     = var.oke_compartment_ocid
  oke_cluster_ocid         = var.oke_cluster_ocid

  # tags
  tags = var.tags

  # IAM
  opt_create_dynamicGroup_and_policies = var.opt_create_dynamicGroup_and_policies

  # Dashboards
  opt_import_dashboards = var.opt_import_dashboards

  # OKE
  oke_is_private = var.oke_is_private

  # Logan
  new_oke_entity_name = null
  new_logGroup_name   = null

  # Helm
  install_helm_chart = local.deploy_helm

  # kubernetes_namespace                  = "oci-onm"
  helmchart_version                     = local.helmchart_version
  path_to_local_onm_helm_chart          = null #"../../../charts/oci-onm/"
  opt_deploy_metric_server              = true
  fluentd_baseDir_path                  = "/var/log"
  user_provided_oci_la_logGroup_ocid    = "ocid1.loganalyticsloggroup.oc1.iad.amaaaaaabulluiqawpwgsjwdaatabraawsmqrvkg6zwrmatou66zrubvpsxq" #null
  user_provided_oke_cluster_entity_ocid = "ocid1.loganalyticsentity.oc1.iad.amaaaaaabulluiqawtcdezoaljkqqet4x5ht6tn2zwg5e6fivwr5uo2ik6ca"   #null
}