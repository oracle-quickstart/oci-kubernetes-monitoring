# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Goal:
#   Format the tags input from OCI RMS stack into acceptable value for Management Agent Response File
#   Ref - https://docs.oracle.com/en-us/iaas/management-agents/doc/install-management-agent-chapter.html#OCIAG-GUID-3008AAB9-B871-47B6-BC05-3A6FE5BDD470

variable "tags" {
  type    = object({ freeformTags = map(string), definedTags = map(string) })
  default = { "freeformTags" = {}, "definedTags" = {} }
}

# tags = {
#   "definedTags" = tomap({
#     "Oracle-Recommended-Tags.ResourceOwner" = "paritosh"
#     "Oracle-Recommended-Tags.ResourceType" = "DevResource"
#     "OracleInternalReserved.OwnerEmail" = "paritosh.paliwal@oracle.com"
#   })
#   "freeformTags" = tomap({
#     "project" = "logan"
#     "test_number" = "1"
#   })
# }

locals {
  freeform_tags = var.tags.freeformTags
  # freeform_tags_string = "{{\"project\": \"logan\",{\"test_number\": \"1\"}"

  freeform_tags_string = "[${join(",", [for key, value in var.tags.freeformTags : "{\"${key}\": \"${value}\"}"])}]"
  # freeform_tags_string = "[{\"project\": \"logan\"},{\"test_number\": \"1\"}]"


  defined_tags = var.tags.definedTags
  # defined_tags = tomap({
  # "Oracle-Recommended-Tags.ResourceOwner" = "paritosh"
  # "Oracle-Recommended-Tags.ResourceType" = "DevResource"
  # "OracleInternalReserved.OwnerEmail" = "paritosh.paliwal@oracle.com"
  # })

  defined_tag_list_by_ns = { for key, value in local.defined_tags : "\"${split(".", key)[0]}\"" => "\"${split(".", key)[1]}\": \"${value}\""... }
  # defined_tag_list_by_ns = {
  # "\"Oracle-Recommended-Tags\"" = [
  #   "\"ResourceOwner\": \"paritosh\"",
  #   "\"ResourceType\": \"DevResource\"",
  # ]
  # "\"OracleInternalReserved\"" = [
  #   "\"OwnerEmail\": \"paritosh.paliwal@oracle.com\"",
  # ]
  # }

  defined_tags_by_ns = { for ns, tag_list in local.defined_tag_list_by_ns : ns => "{ ${join(", ", [for tag in tag_list : "${tag}"])} }" }
  # defined_tags_by_ns = {
  # "\"Oracle-Recommended-Tags\"" = "{\"ResourceOwner\": \"paritosh\"}, {\"ResourceType\": \"DevResource\"}"
  # "\"OracleInternalReserved\"" = "{\"OwnerEmail\": \"paritosh.paliwal@oracle.com\"}"
  # }

  defined_tags_list = [for ns, tags in local.defined_tags_by_ns : "{${ns} : ${tags}}"]
  # defined_tags_list = [
  #   "{\"Oracle-Recommended-Tags\" : { \"ResourceOwner\": \"paritosh\", \"ResourceType\": \"DevResource\" }}",
  #   "{\"OracleInternalReserved\" : { \"OwnerEmail\": \"paritosh.paliwal@oracle.com\" }}",

  defined_tags_string = "[${join(", ", local.defined_tags_list)}]"
  # defined_tags_string = "[{\"Oracle-Recommended-Tags\" : { \"ResourceOwner\": \"paritosh\", \"ResourceType\": \"DevResource\" }}, {\"OracleInternalReserved\" : { \"OwnerEmail\": \"paritosh.paliwal@oracle.com\" }}]"

}

output "defined_tags_string" {
  value = local.defined_tags_string
}

output "freeform_tags_string" {
  value = local.freeform_tags_string
}

# # Debug Outputs

# output "tags" {
#   value = var.tags
# }

# output "freeform_tags" {
#   value = local.freeform_tags
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