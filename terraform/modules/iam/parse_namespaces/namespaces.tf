# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "definedTags" {
  type    = map(string)
  default = {}
}

# definedTags = tomap({
#   "Oracle-Recommended-Tags.ResourceOwner" = "paritosh"
#   "Oracle-Recommended-Tags.ResourceUsage" = "DevResource"
# })

locals {
  keys = [for k, v in var.definedTags : split(".", k)]
  # keys = [
  #   tolist([
  #     "Oracle-Recommended-Tags",
  #     "ResourceOwner",
  #   ]),
  #   tolist([
  #     "Oracle-Recommended-Tags",
  #     "ResourceUsage",
  #   ]),
  # ]

  namespaces = distinct([for ns in local.keys : ns[0] if length(ns) > 0])
  # namespaces = tolist([
  #   "Oracle-Recommended-Tags",
  # ])

}

# output "keys" {
#   value = local.keys
# }

output "namespaces" {
  value = local.namespaces
}