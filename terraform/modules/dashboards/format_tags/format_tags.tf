# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tags" {
  type    = object({ freeformTags = map(string), definedTags = map(string) })
  default = { "freeformTags" = {}, "definedTags" = {} }
}

# "freeformTags" = {
#   "project" = "logan",
#   "owner"   = "paritosh"
# },
# "definedTags" = {
#   "Oracle-Recommended-Tags.ResourceOwner" = "paritosh",
#   "Oracle-Recommended-Tags.ResourceType"  = "DevResource",
#   "OracleInternalReserved.OwnerEmail"     = "paritosh.paliwal@oracle.com"
# }

locals {
  freeform_tags = var.tags.freeformTags
  # freeform_tags = tomap({
  #   "owner" = "paritosh"
  #   "project" = "logan"
  # })

  freeform_tags_string = "{${join(",", [for key, value in var.tags.freeformTags : "\"${key}\": \"${value}\""])}}"
  # freeform_tags_string = "{\"owner\": \"paritosh\",\"project\": \"logan\"}"

  defined_tags = var.tags.definedTags
  # defined_tags = tomap({
  #   "Oracle-Recommended-Tags.ResourceOwner" = "paritosh"
  #   "Oracle-Recommended-Tags.ResourceType" = "DevResource"
  #   "OracleInternalReserved.OwnerEmail" = "paritosh.paliwal@oracle.com"
  # })

  defined_tag_list_by_ns = { for key, value in local.defined_tags : "\"${split(".", key)[0]}\"" => "\"${split(".", key)[1]}\": \"${value}\""... }
  # defined_tag_list_by_ns = {
  #   "\"Oracle-Recommended-Tags\"" = [
  #     "\"ResourceOwner\": \"paritosh\"",
  #     "\"ResourceType\": \"DevResource\"",
  #   ]
  #   "\"OracleInternalReserved\"" = [
  #     "\"OwnerEmail\": \"paritosh.paliwal@oracle.com\"",
  #   ]
  # }

  defined_tags_by_ns = { for ns, tag_list in local.defined_tag_list_by_ns : ns => join(", ", tag_list) }
  # defined_tags_by_ns = {
  #   "\"Oracle-Recommended-Tags\"" = "\"ResourceOwner\": \"paritosh\", \"ResourceType\": \"DevResource\""
  #   "\"OracleInternalReserved\"" = "\"OwnerEmail\": \"paritosh.paliwal@oracle.com\""
  # }

  defined_tags_list = [for ns, tags in local.defined_tags_by_ns : "${ns}: {${tags}}"]
  # defined_tags_list = [
  #   "\"Oracle-Recommended-Tags\": {\"ResourceOwner\": \"paritosh\", \"ResourceType\": \"DevResource\"}",
  #   "\"OracleInternalReserved\": {\"OwnerEmail\": \"paritosh.paliwal@oracle.com\"}",
  # ]

  # Expected format of tags: https://docs.oracle.com/en-us/iaas/api/#/en/managementdashboard/20200901/ManagementDashboardImportDetails/

  defined_tags_string = "{${join(", ", local.defined_tags_list)}}"
  # defined_tags_string = "{\"Oracle-Recommended-Tags\": {\"ResourceOwner\": \"paritosh\", \"ResourceType\": \"DevResource\"}, \"OracleInternalReserved\": {\"OwnerEmail\": \"paritosh.paliwal@oracle.com\"}}"
}

output "defined_tags_string" {
  value = local.defined_tags_string
}

output "freeform_tags_string" {
  value = local.freeform_tags_string
}

## Debug Outputs

# output "tags" {
#   value = var.tags
# }

# output "freeform_tags" {
#   value = local.freeform_tags
# }

# output "freeform_tags_string" {
#   value = local.freeform_tags_string
# }

# output "defined_tags" {
#   value = local.defined_tags
# }

# output "defined_tag_list_by_ns" {
#   value = local.defined_tag_list_by_ns
# }

# output "defined_tags_by_ns" {
#   value = local.defined_tags_by_ns
# }

# output "defined_tags_list" {
#   value = local.defined_tags_list
# }

# output "defined_tags_string" {
#   value = local.defined_tags_string
# }