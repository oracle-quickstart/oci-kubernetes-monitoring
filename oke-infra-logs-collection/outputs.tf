output "invoke_raw_request_script" {
  value = var.debug == true ? join(" ", data.external.invoke_raw_request_script.program) : null
}

output "log_status" {
  value = local.oci_logging_log_data
}
