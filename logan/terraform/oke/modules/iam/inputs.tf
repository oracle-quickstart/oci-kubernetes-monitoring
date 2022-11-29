variable "root_compartment_ocid" {
  type = string
}

# Compartment for creating dashboards and saved-searches
variable "oci_la_compartment_ocid" {
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
