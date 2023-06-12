# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
## Switches - These inputs are meant to be used for development purpose only
## Leave it to default for production use
####

# Enable/Disable helm module 
variable "enable_helm_module" {
  type    = bool
  default = true
}

# Enable/Disable helm template. When set as true, 
# - helm module will generate template file inside ../modules/helm/local directory
# - Setting this to true disables/skips the helm release
variable "generate_helm_template" {
  type    = bool
  default = false
}

# Enable/Disable logan dashboards module
variable "enable_dashboard_module" {
  type    = bool
  default = true
}

# Enable/Disable Management Agent module
# - must be enabled for helm release
variable "enable_mgmt_agent_module" {
  type    = bool
  default = true
}