# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
## Boat configuration - Used for internal developement purpose only.
####

# Option to enable BOAT authentication.
variable "boat_auth" {
  type    = bool
  default = false
}

# OCID of BOAT tenancy.
variable "boat_tenancy_ocid" {
  type    = string
  default = ""
}

####
##  Provider Variables
####

variable "tenancy_ocid" {
  type = string
}

variable "region" {
  type = string
}

variable "user_ocid" {
  type    = string
  default = ""
}

variable "private_key_path" {
  type    = string
  default = ""
}

variable "fingerprint" {
  type    = string
  default = ""
}