# OCI IAM Policies: Complete Setup Guide

> Concise instructions for setting up OCI IAM policies, dynamic groups, user groups, and workload identity policies for OCI Kubernetes Monitoring.

---

## Table of Contents

1. [Dynamic Groups](#dynamic-groups)
2. [User Groups](#user-groups)
3. [Standard IAM Policies (Dynamic / User Group)](#standard-iam-policies)
   - [Metrics Upload Policy](#metrics-upload-policy)
   - [Log & Object Upload Policy](#log--object-upload-policy)
   - [OKE Infra Discovery & Service Logs Collection Policy](#oke-infra-discovery--service-logs-collection-policy-optional)
   - [Tag Namespace Policy](#tag-namespace-policy-optional)
4. [Workload Identity Policies](#workload-identity-policies)
   - [Principal / Scope](#principal--scope-workload-identity)
   - [Tenancy-Level Policies](#tenancy-level-policies)
   - [Compartment-Level Policies](#compartment-level-policies)
   - [Service-Level Policies](#service-level-policies)
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

> **Note:** The OKE dynamic group is *not* required for non-OKE use cases or if using config file-based AuthZ for log monitoring.

---

## User Groups

- Create a user and user group for publishing logs to OCI Log Analytics.
- Reference: [Managing Users](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingusers.htm), [Managing User Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)

> **Note:** This step is *not* required if using OKE and the default (instance principal) AuthZ.

---

## OCI IAM Policies

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

> **Only required if service logs [collection is enabled](./FAQ.md#how-to-enable-oke-infra-discovery-and-corresponding-infra-services-log-collection)**

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

Use these policies when authenticating via **Workload Identity** (recommended for OKE workloads).

### Principal / Scope (Workload Identity)

All workload policies below are constrained to a single workload identity. Replace the `where all { ... }` clause in each policy with:

```text
where all {
  request.principal.type='workload',
  request.principal.namespace='<K8S_Namespace>',
  request.principal.service_account='<K8S_ServiceAccount>',
  request.principal.cluster_id='<OKE_Cluster_OCID>'
}
```

---

### Tenancy-Level Policies

#### 1) Discovery Upload (Required)
```text
Allow any-user to {LOG_ANALYTICS_DISCOVERY_UPLOAD} in tenancy where all { ... }
```
**What it does:** Allows the ONM workload to upload discovery payloads to Log Analytics at tenancy scope.  
**Why needed:** Enables solution discovery/enrichment flows used by the Kubernetes solution UI.

---

#### 2) Tag Namespaces (Required if using defined tags for sources)
```text
Allow any-user to use tag-namespaces in tenancy where all { ... }
```
**What it does:** Allows using defined tag namespaces (tenancy-scoped).  
**Why needed:** If the solution tags resources/sources/entities during onboarding or enrichment.

---

#### 3) Compartment Visibility (Optional)
```text
Allow any-user to inspect compartments in tenancy where all { ... }
```
**What it does:** Allows the workload identity to resolve compartment metadata via Identity APIs.  
**Why needed:** Some services (notably **OCI Logging Search**) may fail with misleading "compartment not found" errors if the principal cannot "see" the compartment.  
**Least-privilege note:** Tenancy-wide visibility; keep the workload constraints and remove if not required.

---

### Compartment-Level Policies

Compartment references used below:
- `<OKE_Compartment_OCID>` — where OKE, VCN/subnets, LBs, and node pools live (sometimes split across compartments)
- `<ONM_Compartment_OCID>` — where Observability resources live (Log Analytics log group, entities, service connectors, etc.)

---

#### Log Analytics Ingestion / Entities

##### 4) Log Upload to Log Analytics (Required)
```text
Allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID> where all { ... }
```
**What it does:** Allows uploading logs into a Log Analytics log group.  
**Why needed:** Fluentd/collectors ship Kubernetes logs to Log Analytics.

---

##### 5) Log Analytics Entity Read (Required)
```text
Allow any-user to read loganalytics-entity in compartment id <ONM_Compartment_OCID> where all { ... }
```
**What it does:** Allows reading Log Analytics entity metadata.  
**Why needed:** Solution UI/topology/correlation relies on entity metadata.

---

#### OKE + Infra Discovery

##### 6) OKE Cluster Read (Required for cluster discovery)
```text
Allow any-user to {CLUSTER_READ} in compartment id <OKE_Compartment_OCID> where all { ... }
```
**What it does:** Allows reading OKE cluster details (e.g., name/version/state).  
**Why needed:** Kubernetes solution discovery/enrichment for cluster-level info.  
**Typical test:** `ContainerEngineClient.get_cluster()` from the pod.

---

##### 7) Node Pools Read (Required for node pool discovery)
```text
Allow any-user to read cluster-node-pools in compartment id <OKE_Compartment_OCID> where all { ... }
```
**What it does:** Allows reading node pool metadata for the cluster.  
**Why needed:** Node pool enrichment/topology.

---

##### 8) VCN Inspect (Required for network topology)
```text
Allow any-user to inspect vcns in compartment id <OKE_Compartment_OCID> where all { ... }
```
**What it does:** Allows metadata-only visibility of VCNs.  
**Why needed:** Network enrichment/topology mapping.

---

##### 9) Subnet Inspect (Required for network topology)
```text
Allow any-user to inspect subnets in compartment id <OKE_Compartment_OCID> where all { ... }
```
**What it does:** Allows metadata-only visibility of subnets.  
**Why needed:** Network enrichment/topology mapping.

---

##### 10) Load Balancer Read (Optional)
```text
Allow any-user to read load-balancers in compartment id <OKE_Compartment_OCID> where all { ... }
```
**What it does:** Allows reading LB metadata/config.  
**Why needed:** Correlate Kubernetes Services of type `LoadBalancer` with OCI LBs.

---

##### 11) Load Balancer Use (Optional / provisioning-time)
```text
Allow any-user to use load-balancers in compartment id <OKE_Compartment_OCID> where all { ... }
```
**What it does:** Allows "use" operations on LB resources.  
**Why needed:** Some automation/integrations may need to reference/associate LB resources without full manage.

---

#### OCI Logging

##### 12) Manage OCI Logging Log Groups (Optional / provisioning-time)
```text
Allow any-user to manage log-groups in compartment id <ONM_Compartment_OCID> where all { ... }
```
**What it does:** Create/update/delete OCI Logging log groups.  
**Why needed:** Only if the solution provisions log groups automatically.  
**Least-privilege warning:** High privilege; prefer `use log-groups` if possible.

---

##### 13) Use OCI Logging Log Groups (Optional)
```text
Allow any-user to use log-groups in compartment id <ONM_Compartment_OCID> where all { ... }
```
**What it does:** Allows referencing/using existing OCI Logging log groups.  
**Why needed:** Attach/configure logging resources without full manage.

---

##### 14) Read OCI Logging Log Content (Optional)
```text
Allow any-user to read log-content in compartment id <OKE_Compartment_OCID> where all { ... }
```
**What it does:** Allows reading log entries via **OCI Logging Search** API.  
**Why needed:** Only if your ONM workflow queries OCI Logging directly (distinct from Log Analytics).

---

#### Resource Manager (Optional / provisioning-time)

##### 15) Manage ORM Stacks
```text
Allow any-user to manage orm-stacks in compartment id <ONM_Compartment_OCID> where all { ... }
```
**What it does:** Create/update/delete Resource Manager stacks.  
**Least-privilege warning:** Powerful; not usually needed at runtime.

---

##### 16) Manage ORM Jobs
```text
Allow any-user to manage orm-jobs in compartment id <ONM_Compartment_OCID> where all { ... }
```
**What it does:** Run/monitor plan/apply jobs for stacks.  
**Least-privilege warning:** Powerful; not usually needed at runtime.

---

#### Infrastructure Updates (High Privilege / provisioning-time only)

##### 17) Subnet Update
```text
Allow any-user to {SUBNET_UPDATE} in compartment id <OKE_Compartment_OCID> where all { ... }
```
**What it does:** Modify subnet configuration.  
**Least-privilege warning:** Network-impacting; only add if automation updates subnet settings.

---

##### 18) Cluster Update
```text
Allow any-user to {CLUSTER_UPDATE} in compartment id <OKE_Compartment_OCID> where all { ... }
```
**What it does:** Modify OKE cluster configuration.  
**Least-privilege warning:** Cluster-impacting; only add if onboarding automation updates cluster settings.

---

#### Service Connector Hub (Optional / provisioning-time)

##### 19) Manage Service Connectors
```text
Allow any-user to manage serviceconnectors in compartment id <ONM_Compartment_OCID> where all { ... }
```
**What it does:** Create/update/delete Service Connector resources.  
**Why needed:** If you route OCI Logging → Log Analytics via Service Connector Hub.  
**Least-privilege warning:** Can redirect data flows.

---

### Service-Level Policies

#### 20) Service Connector Principal → Log Analytics Upload
```text
Allow any-user to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID>
where all {request.principal.type='serviceconnector', request.principal.compartment.id='<ONM_Compartment_OCID>'}
```
**What it does:** Allows the Service Connector resource principal to deliver logs into Log Analytics.  
**Why needed:** When Service Connector Hub is used for ingestion.

---

#### 21) Log Analytics Service Principal Read (Service-side enrichment)
```text
Allow service loganalytics to {VCN_READ,SUBNET_READ,LOAD_BALANCER_READ,CLUSTER_READ,VNIC_READ} in compartment id <OKE_Compartment_OCID>
```
**What it does:** Allows Log Analytics service to read infra metadata for enrichment.  
**Why needed:** Some solution experiences rely on service-side discovery/enrichment.

---

## Placeholders Reference

Replace all placeholders before use:

| Placeholder | Description |
|---|---|
| `<ONM_Compartment_OCID>` | Compartment where Observability/monitoring resources live |
| `<OKE_Cluster_Compartment_OCID>` | Compartment of the OKE cluster (used in dynamic group rule) |
| `<OKE_Compartment_OCID>` | Compartment where OKE, VCN, subnets, LBs, node pools live |
| `<OKE_Cluster_OCID>` | OCID of the specific OKE cluster |
| `<Compartment_OCID>` | Generic compartment OCID (service connector policy) |
| `<OCI_Management_Agent_Dynamic_Group>` | Name of the Management Agent dynamic group |
| `<OKE_Instances_Dynamic_Group>` | Name of the OKE instances dynamic group |
| `<User_Group>` | Name of the user group for log publishing |
| `<K8S_Namespace>` | Kubernetes namespace for workload identity |
| `<K8S_ServiceAccount>` | Kubernetes service account for workload identity |
| Defined tag namespaces | e.g., `'example-ns-1'`, `'example-ns-2'` |

---
For more details, see Oracle documentation:
- [Managing Dynamic Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm)
- [Managing Users](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingusers.htm)
- [Managing User Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)
- [OCI Workload Identity](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contenggrantingworkloadaccesstoresources.htm)
- [OCI IAM Policies](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policies.htm)
- [OKE Enhanced Clusters](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengworkingwithenhancedclusters.htm)