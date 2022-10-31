
### Configure Boat Authentication for OCI; leave unchaged if not using boat authentication
boat_auth         = false # set true to use BOAT Authentication
boat_tenancy_ocid = ""    # <add user OCID>; leave uncganged if boat_auth=false

###  OCI Provider inputs
tenancy_ocid     = "<add tenant OCID here>" # Use Boat tenancy OCID if boat_auth=true
region           = "<add region here>"      # add target region - ex: "us-phoenix-1"
user_ocid        = ""                       # <add user OCID>; leave it empty for cloud-shell
private_key_path = ""                       # <add key path>; leave it empty for cloud-shell
fingerprint      = ""                       # <add key fingerprint>; leave it empty for cloud-shell

###  Stack inputs

# OKE Cluster Compartment
oke_compartment_ocid = "<add compartment OCID for OKE cluster here>"

# OKE Cluster OCID
oke_cluster_ocid = "<add OCID of OKE cluster OCID>"

# Image URL of OCI LA Fluentd Container
# Reference - https://github.com/oracle-quickstart/oci-kubernetes-monitoring#docker-image
container_image_url = "<add image url of fluentd-container image>"

# Kubernetes Namespace in which the monitoring solution to be deployed
kubernetes_namespace = "kube-system" # can change if want to deploy in a custom namespace

# Option to create Kubernetes Namespace
opt_create_kubernetes_namespace = true # If true, kubernetes_namespace will be created if does not exist already

# Compartment for creating dashboards and saved-searches  and logGroup
oci_la_compartment_ocid = "<add compartment OCID for LA Service here>"

# Option to create Logging Analytics
opt_use_existing_la_logGroup = true # if ture, oci_la_logGroup_name must be set

# *New* OCI Logging Analytics LogGroup Name
oci_la_logGroup_name = "<add new name for logGroup here>" # leave it unchanged, if opt_use_existing_la_logGroup=false

# OCI Logging Analytics LogGroup
oci_la_logGroup_id = "" # Add OCID of logGroup if opt_use_existing_la_logGroup=true, leave it empty otherwise

# Option to create Dynamic Group and Policies
opt_create_dynamicGroup_and_policies = true # if fasle; Dynamic Group & Policy won't be created

# Base directory on the node (with read & write permission) to store fluentd plugin's related data
fluentd_baseDir_path = "/var/log" # change as required