# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "private_endpoint_reachable_ip" {
  value = data.oci_resourcemanager_private_endpoint_reachable_ip.rechable_ip.ip_address
}