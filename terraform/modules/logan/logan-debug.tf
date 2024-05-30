resource "local_file" "user_provided_entity" {
  count    = !local.create_new_k8s_entity && var.debug ? 1 : 0
  content  = jsonencode(data.oci_log_analytics_log_analytics_entity.user_provided_entity[0])
  filename = "${path.module}/tf-debug/user_provided_entity.json"
}

resource "local_file" "logan_namespaces" {
  count    = var.debug ? 1 : 0
  content  = jsonencode(data.oci_log_analytics_namespaces.logan_namespaces)
  filename = "${path.module}/tf-debug/logan_namespaces.json"
}

data "oci_log_analytics_log_analytics_entity" "stack_created_entity" {
  count                   = var.debug && local.create_new_k8s_entity ? 1 : 0
  log_analytics_entity_id = oci_log_analytics_log_analytics_entity.new_oke_entity[0].id
  namespace               = local.oci_la_namespace
}

resource "local_file" "stack_created_entity" {
  count    = var.debug && local.create_new_k8s_entity ? 1 : 0
  content  = jsonencode(data.oci_log_analytics_log_analytics_entity.stack_created_entity)
  filename = "${path.module}/tf-debug/stack_created_entity.json"
}