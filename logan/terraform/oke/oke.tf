data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = var.oke_cluster_ocid
}

# kubeconfig when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "oke_kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke.content
  filename = "${path.module}/local/kubeconfig"
  count = var.enable_local_testing ? 1 : 0
}

resource "null_resource" "cluster_details" {
    provisioner "local-exec" {
      command = "oci ce cluster get --cluster-id=$CLUSTER_ID > $OUTPUT_FILE"
      #command = "echo 'Hello' > $OUTPUT_FILE"
      environment = {
        CLUSTER_ID = "${var.oke_cluster_ocid}"
        OUTPUT_FILE = "${path.module}/clusterDetails.json"
      }
    }
}

data "local_file" "cluster_details" {
  filename = "${path.module}/clusterDetails.json"
  depends_on = [ null_resource.cluster_details ]
}

locals {
  cluster_details_map = jsondecode(data.local_file.cluster_details.content)
  cluster_name = local.cluster_details_map["data"]["name"]
}