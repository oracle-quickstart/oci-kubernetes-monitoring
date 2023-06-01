# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

####
## livelab
####

## Note - /util/build_stack.sh script modifies below input from "FALSE" to "TRUE", while generating livelab build, hence
##      - Do not add addtional inputs here &
##      - Do not modify this file

variable "livelab_switch" {
  type    = bool
  default = false
}