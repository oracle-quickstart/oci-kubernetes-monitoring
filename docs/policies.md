## OCI IAM Policies: Complete Setup Guide

> Concise instructions for setting up required OCI IAM policies for OCI Kubernetes Monitoring.

## Table of Contents

1. [Placeholders Reference](#placeholders-reference)
2. [Instance Principal Based Policies](#instance-principal-based-policies)
   - [Dynamic Groups](#dynamic-groups)
   - [Policy Statements](#instance-principal-policy-statements)
3. [Workload Identity Based Policies](#workload-identity-based-policies)
   - [Policy Statements](#workload-identity-policy-statements)
4. [User Principal Based Policies](#user-principal-based-policies)
   - [User Groups](#user-groups)
   - [Policy Statements](#user-principal-policy-statements)
5. [References](#references)

## Placeholders Reference

| Placeholder | Description |
|-------------|-------------|
| `<ONM_Compartment_OCID>` | Compartment where Observability/monitoring resources live |
| `<OKE_Cluster_Compartment_OCID>` | Compartment of the OKE cluster (used in dynamic group rule) |
| `<OKE_Compartment_OCID>` | Compartment where OKE, VCN, subnets, LBs, node pools live |
| `<OKE_Cluster_OCID>` | OCID of the specific OKE cluster |
| `<OCI_Management_Agent_Dynamic_Group>` | Name of the Management Agent dynamic group |
| `<OKE_Instances_Dynamic_Group>` | Name of the OKE instances dynamic group |
| `<User_Group>` | Name of the user group for log publishing |
| `<K8S_Namespace>` | Kubernetes namespace (default: `oci-onm`) |
| `<K8S_ServiceAccount>` | Kubernetes service account (default: `oci-onm`) |


## Instance Principal Based Policies

Use these policies when authenticating via **Instance Principal** (default for OKE Basic clusters).

### Dynamic Groups

Create dynamic groups as follows:

**For OCI Management Agent:**
```text
ALL {resource.type='managementagent', resource.compartment.id='<ONM_Compartment_OCID>'}
```

**For OKE Instances:**
```text
ALL {instance.compartment.id='<OKE_Cluster_Compartment_OCID>'}
```

### Instance Principal Policy Statements

#### Required Policies

```text
Allow dynamic-group <OKE_Instances_Dynamic_Group> to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to {LOG_ANALYTICS_DISCOVERY_UPLOAD} in tenancy
Allow dynamic-group <OKE_Instances_Dynamic_Group> to read loganalytics-entity in compartment id <ONM_Compartment_OCID>

Allow dynamic-group <OKE_Instances_Dynamic_Group> to {CLUSTER_READ} in compartment id <OKE_Compartment_OCID> where target.cluster.id='<OKE_Cluster_OCID>'
Allow dynamic-group <OKE_Instances_Dynamic_Group> to read cluster-node-pools in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to inspect vcns in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to inspect subnets in compartment id <OKE_Compartment_OCID>

Allow dynamic-group <OCI_Management_Agent_Dynamic_Group> to use metrics in compartment id <ONM_Compartment_OCID> WHERE target.metrics.namespace = 'mgmtagent_kubernetes_metrics'

Allow resource loganalyticsvrp LogAnalyticsVirtualResource to {VCN_READ,SUBNET_READ,LOAD_BALANCER_READ,CLUSTER_READ,VNIC_READ} in compartment id <OKE_Compartment_OCID>
```

#### OKE Service Logs Collection Policy (Optional)

```text
Allow dynamic-group <OKE_Instances_Dynamic_Group> to read load-balancers in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to use load-balancers in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to manage orm-jobs in compartment id <ONM_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to manage orm-stacks in compartment id <ONM_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to {SUBNET_UPDATE} in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to {CLUSTER_UPDATE} in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to read log-content in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to read log-content in compartment id <ONM_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to use log-groups in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to manage log-groups in compartment id <ONM_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to manage serviceconnectors in compartment id <ONM_Compartment_OCID>

Allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID> where all {request.principal.type='serviceconnector', request.principal.compartment.id='<ONM_Compartment_OCID>'}
```

#### Tag Namespace Policy (Optional)

```text
Allow dynamic-group <OKE_Instances_Dynamic_Group> to use tag-namespaces in tenancy where any {target.tag-namespace.name='example-ns-1', target.tag-namespace.name='example-ns-2'}
```

## Workload Identity Based Policies

Use these policies when authenticating via **Workload Identity** (recommended for OKE Enhanced clusters).

Dynamic group for OKE instances is not required when using WorkloadIdentity. Management Agent dynamic group is still required for metrics collection.

### Workload Identity Condition

All workload identity policies use this condition to scope access to a specific workload:

```text
where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
```

### Workload Identity Policy Statements

#### Required Policies

```text
Allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to {LOG_ANALYTICS_DISCOVERY_UPLOAD} in tenancy where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to read loganalytics-entity in compartment id <ONM_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}

Allow any-user to {CLUSTER_READ} in compartment id <OKE_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to read cluster-node-pools in compartment id <OKE_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to inspect vcns in compartment id <OKE_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to inspect subnets in compartment id <OKE_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}

Allow dynamic-group <OCI_Management_Agent_Dynamic_Group> to use metrics in compartment id <ONM_Compartment_OCID> WHERE target.metrics.namespace = 'mgmtagent_kubernetes_metrics'

Allow resource loganalyticsvrp LogAnalyticsVirtualResource to {VCN_READ,SUBNET_READ,LOAD_BALANCER_READ,CLUSTER_READ,VNIC_READ} in compartment id <OKE_Compartment_OCID>
```

#### OKE Service Logs Collection Policy (Optional)

```text
Allow any-user to read load-balancers in compartment id <OKE_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to use load-balancers in compartment id <OKE_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to manage orm-stacks in compartment id <ONM_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to manage orm-jobs in compartment id <ONM_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to {SUBNET_UPDATE} in compartment id <OKE_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to {CLUSTER_UPDATE} in compartment id <OKE_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to read log-content in compartment id <OKE_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to use log-groups in compartment id <OKE_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to manage log-groups in compartment id <ONM_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
Allow any-user to manage serviceconnectors in compartment id <ONM_Compartment_OCID> where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}

Allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID> where all {request.principal.type='serviceconnector', request.principal.compartment.id='<ONM_Compartment_OCID>'}
```

#### Tag Namespace Policy (Optional)

```text
Allow any-user to use tag-namespaces in tenancy where all {request.principal.type='workload', request.principal.namespace='<K8S_Namespace>', request.principal.service_account='<K8S_ServiceAccount>', request.principal.cluster_id='<OKE_Cluster_OCID>'}
```

## User Principal Based Policies

Use these policies when authenticating via **Config File** (user principal).

It is recommended to use Instance Principal or Workload Identity instead of User Principal for production deployments. Dynamic group for OKE instances is not required when using config file-based authentication.

### User Groups

Create a user and user group for publishing logs to OCI Log Analytics.

Reference: [Managing Users](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingusers.htm), [Managing User Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)

### User Principal Policy Statements

#### Required Policies

```text
Allow group <User_Group> to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID>
Allow group <User_Group> to {LOG_ANALYTICS_DISCOVERY_UPLOAD} in tenancy
Allow group <User_Group> to read loganalytics-entity in compartment id <ONM_Compartment_OCID>

Allow group <User_Group> to {CLUSTER_READ} in compartment id <OKE_Compartment_OCID>
Allow group <User_Group> to read cluster-node-pools in compartment id <OKE_Compartment_OCID>
Allow group <User_Group> to inspect vcns in compartment id <OKE_Compartment_OCID>
Allow group <User_Group> to inspect subnets in compartment id <OKE_Compartment_OCID>

Allow dynamic-group <OCI_Management_Agent_Dynamic_Group> to use metrics in compartment id <ONM_Compartment_OCID> WHERE target.metrics.namespace = 'mgmtagent_kubernetes_metrics'

Allow resource loganalyticsvrp LogAnalyticsVirtualResource to {VCN_READ,SUBNET_READ,LOAD_BALANCER_READ,CLUSTER_READ,VNIC_READ} in compartment id <OKE_Compartment_OCID>
```

#### OKE Service Logs Collection Policy (Optional)

```text
Allow group <User_Group> to read load-balancers in compartment id <OKE_Compartment_OCID>
Allow group <User_Group> to use load-balancers in compartment id <OKE_Compartment_OCID>
Allow group <User_Group> to manage orm-jobs in compartment id <ONM_Compartment_OCID>
Allow group <User_Group> to manage orm-stacks in compartment id <ONM_Compartment_OCID>
Allow group <User_Group> to {SUBNET_UPDATE} in compartment id <OKE_Compartment_OCID>
Allow group <User_Group> to {CLUSTER_UPDATE} in compartment id <OKE_Compartment_OCID>
Allow group <User_Group> to read log-content in compartment id <OKE_Compartment_OCID>
Allow group <User_Group> to read log-content in compartment id <ONM_Compartment_OCID>
Allow group <User_Group> to use log-groups in compartment id <OKE_Compartment_OCID>
Allow group <User_Group> to manage log-groups in compartment id <ONM_Compartment_OCID>
Allow group <User_Group> to manage serviceconnectors in compartment id <ONM_Compartment_OCID>

Allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID> where all {request.principal.type='serviceconnector', request.principal.compartment.id='<ONM_Compartment_OCID>'}
```

#### Tag Namespace Policy (Optional)

```text
Allow group <User_Group> to use tag-namespaces in tenancy where any {target.tag-namespace.name='example-ns-1', target.tag-namespace.name='example-ns-2'}
```

## References

- [Managing Dynamic Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm)
- [Managing Users](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingusers.htm)
- [Managing User Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)
- [OCI Workload Identity](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contenggrantingworkloadaccesstoresources.htm)
- [OCI IAM Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policies.htm)
- [OKE Enhanced Clusters](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengworkingwithenhancedclusters.htm)
- [Log Analytics Virtual Resource Principal](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/create-policies-log-analytics.html)