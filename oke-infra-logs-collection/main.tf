# Prepare list of resources (in JSON format) to pass them to Python script
locals {
  oke_ocid = [for k, v in var.cluster : k][0]
  oke_id   = substr(local.oke_ocid, -11, 11)
}

locals {
  python_script       = "filter-logs.py"
  python_path         = "python3" # [for-rms 'python3' or '/usr/bin/python3']
  operation_initiator = "oci-kubernetes-monitoring"

  subnet_list        = format("[%s]", join(", ", [for key, value in var.subnets : jsonencode(value)]))
  load_balancer_list = format("[%s]", join(", ", [for key, value in var.load_balancers : jsonencode(value)]))
  cluster_details    = format("[%s]", join(", ", [for key, value in var.cluster : jsonencode(value)]))

  freeform_managedBy_tag = { "managedBy" : local.operation_initiator }

  freeform_tags = merge(var.tags.freeformTags, local.freeform_managedBy_tag)
  defined_tags  = var.tags.definedTags

  # Read collected data (fetched by Python script)
  oci_logging_log_data = jsondecode(data.external.invoke_raw_request_script.result.value)

  logs_managed_by_stack = {
    for index, resource in local.oci_logging_log_data["logs"] :
    "${resource.ocid}_${resource.log_type}" => resource
    if resource.managed_by_stack == true
  }
}

# Invoke Python script
data "external" "invoke_raw_request_script" {
  program = [local.python_path, local.python_script,
    "-r", "${var.oci_region}",
    "-s", "${local.subnet_list}",
    "-l", "${local.load_balancer_list}",
    "-k", "${local.cluster_details}",
    "-t", "${local.operation_initiator}",
    "-d", "${var.oci_domain}",
  "-c", "${var.oci_config_file == null ? "None" : var.oci_config_file}"]
}

# resource "time_static" "setup_time" {}

locals {
  oci_logging_log_group_name = "logging_analytics_automatic_discovery_${local.oke_id}_source"
}

# Log group for OCI logging service (logging_analytics_automatic_discovery_source)
resource "oci_logging_log_group" "logging_analytics_automatic_discovery_source" {
  count          = length(local.logs_managed_by_stack) > 0 ? 1 : 0
  compartment_id = var.onm_compartment_id
  display_name   = local.oci_logging_log_group_name

  description = "This log group was automatically created when you configured monitoring for OKE cluster - ${local.oke_ocid}"

  freeform_tags = local.freeform_tags
  defined_tags  = local.defined_tags

  lifecycle {
    ignore_changes = [display_name, freeform_tags, defined_tags]
  }
}

locals {
  oci_logging_log_group_ocid = length(local.logs_managed_by_stack) > 0 ? (
  oci_logging_log_group.logging_analytics_automatic_discovery_source[0].id) : null

  logs_enabled_via_stack = { for key, log in oci_logging_log.logs : key => log }

  logs_already_enabled = { for key, log in local.oci_logging_log_data["logs"] :
  "${log.ocid}_${log.log_type}" => log if log.is_log_enabled == true }

  merged_object_log_details_map = merge(local.logs_enabled_via_stack, local.logs_already_enabled)
}

# Enable log collections
resource "oci_logging_log" "logs" {
  for_each = local.logs_managed_by_stack

  display_name = "${replace(each.value.name, " ", "_")}_LA_${each.value.log_type}"
  log_group_id = local.oci_logging_log_group_ocid
  log_type     = "SERVICE"

  configuration {
    source {
      category    = each.value.log_type
      resource    = each.value.ocid
      service     = each.value.service
      source_type = "OCISERVICE"
    }

    compartment_id = var.onm_compartment_id
  }

  freeform_tags = local.freeform_tags
  defined_tags  = local.defined_tags

  lifecycle {
    ignore_changes = [display_name, freeform_tags, defined_tags]
  }
}

# Service Connector (logging_analytics_oci_discovery)
resource "oci_sch_service_connector" "logging_analytics_oci_discovery" {
  count          = length(local.merged_object_log_details_map) > 0 ? 1 : 0
  compartment_id = var.onm_compartment_id
  display_name   = "logging_analytics_oke_discovery_${local.oke_id}"
  description    = "This service connector was automatically created when you configured monitoring for OKE cluster - ${local.oke_ocid}"

  # TODO: Duplicate log sources
  source {
    kind = "logging"
    dynamic "log_sources" {
      for_each = local.merged_object_log_details_map
      iterator = log_detail
      content {
        compartment_id = var.onm_compartment_id
        log_group_id   = log_detail.value.log_group_id
        log_id         = log_detail.value.id
      }
    }
  }

  target {
    kind         = "loggingAnalytics"
    log_group_id = var.log_analytics_log_group
  }

  freeform_tags = local.freeform_tags
  defined_tags  = local.defined_tags

  depends_on = [oci_logging_log.logs]

  lifecycle {
    ignore_changes = [display_name, freeform_tags, defined_tags]
  }
}