## OCI IAM Policies: Complete Setup Guide

> Concise instructions for setting up OCI IAM policies, dynamic groups, user groups, and workload identity policies for OCI Kubernetes Monitoring.

---

## Table of Contents

1. [Dynamic Groups](#dynamic-groups)
2. [User Groups](#user-groups)
3. [Standard IAM Policies (Dynamic / User Group)](#standard-iam-policies)
4. [Workload Identity Policies](#workload-identity-policies)
5. [Placeholders Reference](#placeholders-reference)
6. [References](#references)

---

## Dynamic Groups

Create dynamic groups as follows (replace all placeholders in angle brackets):

**For OCI Management Agent:**
```text
ALL {resource.type='managementagent', resource.compartment.id='<ONM_Compartment_OCID>'}
```

**For OKE Instances:**
```text
ALL {instance.compartment.id='<OKE_Cluster_Compartment_OCID>'}
```

> **Note:** The OKE dynamic group is *not* required for non-OKE use cases or if using config file-based AuthZ or WorkloadIdentity for log monitoring.

---

## User Groups

- Create a user and user group for publishing logs to OCI Log Analytics.
- Reference: [Managing Users](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingusers.htm), [Managing User Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)

> **Note:** This step is *not* required if using OKE and the default (instance principal) AuthZ or WorkloadIdentity.

---

## Standard IAM Policies

These policies apply when using **Dynamic Groups** or **User Groups** (non-workload identity).

### Metrics Upload Policy

```text
Allow dynamic-group <OCI_Management_Agent_Dynamic_Group> to use metrics in compartment id <ONM_Compartment_OCID> WHERE target.metrics.namespace = 'mgmtagent_kubernetes_metrics'
```

---

### Log & Object Upload Policy

**If using Dynamic Group:**
```text
Allow dynamic-group <OKE_Instances_Dynamic_Group> to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to {LOG_ANALYTICS_DISCOVERY_UPLOAD} in tenancy
```

**OR — If using User Group:**
```text
Allow group <User_Group> to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID>
Allow group <User_Group> to {LOG_ANALYTICS_DISCOVERY_UPLOAD} in compartment id <ONM_Compartment_OCID>
```

---

### OKE Infra Discovery & Service Logs Collection Policy (Optional)

> **Only required if service logs collection is enabled**

```text
Allow dynamic-group <OKE_Instances_Dynamic_Group> to {CLUSTER_READ} in compartment id <OKE_Compartment_OCID> where target.cluster.id='<OKE_Cluster_OCID>'
Allow dynamic-group <OKE_Instances_Dynamic_Group> to read cluster-node-pools in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to inspect vcns in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to inspect subnets in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to read load-balancers in compartment id <OKE_Compartment_OCID>

Allow dynamic-group <OKE_Instances_Dynamic_Group> to read loganalytics-entity in compartment id <ONM_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to manage orm-jobs in compartment id <ONM_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to manage orm-stacks in compartment id <ONM_Compartment_OCID>

Allow dynamic-group <OKE_Instances_Dynamic_Group> to use load-balancers in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to {SUBNET_UPDATE} in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to {CLUSTER_UPDATE} in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to read log-content in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to read log-content in compartment id <ONM_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to use log-groups in compartment id <OKE_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to manage log-groups in compartment id <ONM_Compartment_OCID>

Allow dynamic-group <OKE_Instances_Dynamic_Group> to manage serviceconnectors in compartment id <ONM_Compartment_OCID>
Allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <Compartment_OCID> where all {request.principal.type='serviceconnector', request.principal.compartment.id='<Compartment_OCID>'}

Allow service loganalytics to {VCN_READ,SUBNET_READ,LOAD_BALANCER_READ,CLUSTER_READ,VNIC_READ} in compartment id <OKE_Compartment_OCID>
```

---

### Tag Namespace Policy (Optional)

> Only required if using defined tags.

```text
Allow dynamic-group <OKE_Instances_Dynamic_Group> to use tag-namespaces in tenancy where any {target.tag-namespace.name='example-ns-1', target.tag-namespace.name='example-ns-2'}
```

---

## Workload Identity Policies

Use these policies when authenticating via **Workload Identity** (recommended for OKE Enhanced clusters).

> **Note:** Dynamic group for OKE instances is *not* required when using WorkloadIdentity.

---

### Workload Identity Condition

All workload identity policies use this condition to scope access to a specific workload. Replace the placeholders with your values:

```text
where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}
```

---

### Log & Discovery Upload Policy (Required)

```text
Allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to {LOG_ANALYTICS_DISCOVERY_UPLOAD} in tenancy where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to read loganalytics-entity in compartment id <ONM_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}
```

---

### OKE Infra Discovery Policy (Required)

```text
Allow any-user to {CLUSTER_READ} in compartment id <OKE_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to read cluster-node-pools in compartment id <OKE_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to inspect vcns in compartment id <OKE_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to inspect subnets in compartment id <OKE_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}
```

---

### Service Logs Collection Policy (Optional)

> **Only required if service logs collection is enabled**

```text
Allow any-user to read load-balancers in compartment id <OKE_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to use load-balancers in compartment id <OKE_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to manage orm-stacks in compartment id <ONM_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to manage orm-jobs in compartment id <ONM_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to {SUBNET_UPDATE} in compartment id <OKE_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to {CLUSTER_UPDATE} in compartment id <OKE_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to read log-content in compartment id <OKE_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to use log-groups in compartment id <OKE_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to manage log-groups in compartment id <ONM_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to manage serviceconnectors in compartment id <ONM_Compartment_OCID> where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}

Allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID> where all {
  request.principal.type='serviceconnector',
  request.principal.compartment.id='<ONM_Compartment_OCID>'
}

Allow service loganalytics to {VCN_READ,SUBNET_READ,LOAD_BALANCER_READ,CLUSTER_READ,VNIC_READ} in compartment id <OKE_Compartment_OCID>
```

---

### Tag Namespace Policy (Optional)

> Only required if using defined tags.

```text
Allow any-user to use tag-namespaces in tenancy where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}
```

---

## Placeholders Reference

Replace all placeholders before use:

| Placeholder | Description |
|-------------|-------------|
| `<ONM_Compartment_OCID>` | Compartment where Observability/monitoring resources live |
| `<OKE_Cluster_Compartment_OCID>` | Compartment of the OKE cluster (used in dynamic group rule) |
| `<OKE_Compartment_OCID>` | Compartment where OKE, VCN, subnets, LBs, node pools live |
| `<OKE_Cluster_OCID>` | OCID of the specific OKE cluster |
| `<Compartment_OCID>` | Generic compartment OCID (service connector policy) |
| `<OCI_Management_Agent_Dynamic_Group>` | Name of the Management Agent dynamic group |
| `<OKE_Instances_Dynamic_Group>` | Name of the OKE instances dynamic group |
| `<User_Group>` | Name of the user group for log publishing |
| `<K8S_Namespace>` | Kubernetes namespace (default: `oci-onm`) |
| `<K8S_ServiceAccount>` | Kubernetes service account (default: `oci-onm`) |

---
For more details, see Oracle documentation:
- [Managing Dynamic Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm)
- [Managing Users](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingusers.htm)
- [Managing User Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)
- [OCI Workload Identity](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contenggrantingworkloadaccesstoresources.htm)
- [OCI IAM Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policies.htm)
- [OKE Enhanced Clusters](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengworkingwithenhancedclusters.htm)