# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tags" {
  type    = object({ freeformTags = map(string), definedTags = map(string) })
  default = { "freeformTags" = {}, "definedTags" = {} }
}

# tags = {
#   "freeformTags" = { "project" = "logan", "test_number" = "1" },
#   "definedTags" = {
#     "Oracle-Recommended-Tags.ResourceOwner" = "testOwner", #,
#     "Oracle-Recommended-Tags.ResourceUsage" = "testUsage", #,
#     "test.key"                              = "testOwner"
#   }
# }

locals {
  freeform_tags_string = "{${join(", ", [for key, value in var.tags.freeformTags : "\"${key}\" = \"${value}\""])}}"

  defined_tags_string = "{${join(", ", [for key, value in var.tags.definedTags : "\"${key}\" = \"${value}\""])}}"

  tags_string = "{ \"freeformTags\" =  ${local.freeform_tags_string}, \"definedTags\" = ${local.defined_tags_string} }"
}

output "tags_string" {
  value = local.tags_string
}

output "tags_string_base64" {
  value = base64encode(local.tags_string)
}

output "tags_jsonencode_base64" {
  value = base64encode(jsonencode(var.tags))
}

# output "defined_tags_string" {
#   value = local.defined_tags_string
# }

# output "freeform_tags_string" {
#   value = local.freeform_tags_string
# }

# Example output:
# tags_string = "{ \"freeformTags\" =  {\"project\" = \"logan\", \"test_number\" = \"1\"}, \"definedTags\" = {\"Oracle-Recommended-Tags.ResourceOwner\" = \"testOwner\", \"Oracle-Recommended-Tags.ResourceUsage\" = \"testUsage\", \"test.key\" = \"testOwner\"} }"