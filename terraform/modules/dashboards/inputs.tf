# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Compartment for creating dashboards and it's associated saved-searches
variable "compartment_ocid" {
  type = string
}

variable "debug" {
  type    = bool
  default = false
}