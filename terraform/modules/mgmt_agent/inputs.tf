# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# A unique key to be associated with a single OKE cluster
variable "uniquifier" {
  type = string
}

# OCID of compartment where management agent installation key is to be created
variable "compartment_ocid" {
  type = string
}