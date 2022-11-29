variable "tenancy_ocid" {
  type = string
}

# Option to create Logging Analytics
variable "use_existing_logGroup" {
  type = bool
}

# Compartment for creating dashboards and saved-searches
variable "compartment_ocid" {
  type = string
}

# OCI Logging Analytics LogGroup OCID
variable "existing_logGroup_id" {
  type    = string
}

# New Log Group to collect Kubernetes data
variable "new_logGroup_name" {
  type    = string
}
