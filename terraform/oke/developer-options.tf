# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
## Switches - These inputs are meant to be used for development purpose only
## Leave it to default for production use
####

# Enable/Disable livelab module
variable "toggle_livelab_module" {
  type    = bool
  default = true
}

# Enable/Disable helm module 
variable "toggle_helm_module" {
  type    = bool
  default = true
}

# when false, public helm repo is used for deployment 
variable "toggle_use_local_helm_chart" {
  type    = bool
  default = false
}

# Enable/Disable helm template. When set as true, 
# - helm module will generate template file inside ../modules/helm/local directory
# - Setting this to true disables/skips the helm release
variable "toggle_generate_helm_template" {
  type    = bool
  default = false
}

# Enable/Disable helm installation. 
variable "toggle_install_helm" {
  type    = bool
  default = true
}

# Enable/Disable logan dashboards module
variable "toggle_dashboards_module" {
  type    = bool
  default = true
}

# Enable/Disable management agent module
variable "toggle_mgmt_agent_module" {
  type    = bool
  default = true
}

# Enable/Disable management agent module
variable "toggle_logan_module" {
  type    = bool
  default = true
}

# Enable/Disable IAM module
variable "toggle_iam_module" {
  type    = bool
  default = true
}