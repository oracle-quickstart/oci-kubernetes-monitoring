variable "private_endpoint_ocid" {
  type = string
  validation {
    condition     = var.private_endpoint_ocid == null ? true : length(regexall("^ocid1\\.ormprivateendpoint\\S*$", var.private_endpoint_ocid)) > 0
    error_message = "Incorrect format: var.private_endpoint_ocid"
  }
}

variable "oke_subnet_ocid" {
  type = string
  validation {
    condition     = var.oke_subnet_ocid == null ? true : length(regexall("^ocid1\\.subnet\\S*$", var.oke_subnet_ocid)) > 0
    error_message = "Incorrect format: var.oke_subnet_ocid"
  }
}

variable "pe_compartmnet_ocid" {
  type     = string
  nullable = false
}

variable "oke_vcn_ocid" {
  type = string
}

variable "private_ip_address" {
  type     = string
  nullable = false
}

variable "tags" {
  type    = object({ freeformTags = map(string), definedTags = map(string) })
  default = { "freeformTags" = {}, "definedTags" = {} }
}