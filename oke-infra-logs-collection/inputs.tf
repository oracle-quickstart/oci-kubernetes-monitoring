# ex: us-ashburn-1
variable "oci_region" {
  type = string
}

# ex: oraclecloud.com
variable "oci_domain" {
  type    = string
  default = "None" # Hard coded value for python script, filter-logs.py
}

variable "load_balancers" {
  type = map(object({
    name           = string
    ocid           = string
    compartment_id = string
  }))
}

variable "subnets" {
  type = map(object({
    name           = string
    ocid           = string
    compartment_id = string
  }))
}

variable "cluster" {
  type = map(object({
    name           = string
    ocid           = string
    compartment_id = string
  }))
}

variable "onm_compartment_id" {
  type = string
}

variable "log_analytics_log_group" {
  type = string
}

variable "tags" {
  type    = object({ freeformTags = map(string), definedTags = map(string) })
  default = { "freeformTags" = {}, "definedTags" = {} }
}

#####
## Only for Dev Testing
#####

variable "oci_tenancy_ocid" {
  type    = string
  default = null
}

variable "oci_user_ocid" {
  type    = string
  default = null
}

variable "private_key_path" {
  type    = string
  default = null
}

variable "fingerprint" {
  type    = string
  default = null
}

variable "oci_config_file" {
  type    = string
  default = null
}

variable "debug" {
  type    = bool
  default = false
}