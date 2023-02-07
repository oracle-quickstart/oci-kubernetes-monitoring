# tenancy OCID
variable "tenancy_ocid" {
  type = string
}

# Option to create Logging Analytics
variable "create_new_logGroup" { # opt_create_new_logGroup
  type    = bool
  default = false
}

# Compartment for creating new LogGroup, if opted in by user
variable "compartment_ocid" {
  type = string
}

# OCI Logging Analytics LogGroup OCID
variable "existing_logGroup_id" {
  type    = string
  default = ""
}

# New Log Group to collect Kubernetes data
variable "new_logGroup_name" {
  type    = string
  default = "" // This is expected to rasie terraform error if ran with default value
}
