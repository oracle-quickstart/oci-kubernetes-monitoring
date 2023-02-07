# tenancy ocid
variable "root_compartment_ocid" {
  type = string
}

# Compartment of OCI Logging Analytics LogGroup
variable "oci_la_logGroup_compartment_ocid" {
  type = string
}

# OKE Cluster Compartment
variable "oke_compartment_ocid" {
  type = string
}

# OKE Cluster OCID
variable "oke_cluster_ocid" {
  type = string
}
