## OCI IAM Policies: Setup Guide

> Concise instructions for setting up required OCI IAM policies, dynamic groups, and user groups for OCI Kubernetes Monitoring.

---

### Dynamic Groups

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

### User Groups

- Create a user and user group for publishing logs to OCI Log Analytics.
- Reference: [Managing Users](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingusers.htm), [Managing User Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)
> **Note:** This step is *not* required if using OKE and the default (instance principal) AuthZ.

---

### OCI IAM Policies

#### Metrics Upload Policy
```text
Allow dynamic-group <OCI_Management_Agent_Dynamic_Group> to use metrics in compartment id <ONM_Compartment_OCID> WHERE target.metrics.namespace = 'mgmtagent_kubernetes_metrics'
```

---

#### Log & Object Upload Policy

**If using Dynamic Group:**
```text
Allow dynamic-group <OKE_Instances_Dynamic_Group> to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID>
Allow dynamic-group <OKE_Instances_Dynamic_Group> to {LOG_ANALYTICS_DISCOVERY_UPLOAD} in tenancy
```
**OR**  
**If using User Group:**
```text
Allow group <User_Group> to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment id <ONM_Compartment_OCID>
Allow group <User_Group> to {LOG_ANALYTICS_DISCOVERY_UPLOAD} in compartment id <ONM_Compartment_OCID>
```

---

#### OKE Infra Discovery & Service Logs Collection Policy (Optional)

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

#### Tag Namespace Policy (Optional, if using defined tags)

```text
Allow dynamic-group <OKE_Instances_Dynamic_Group> to use tag-namespaces in tenancy where any {target.tag-namespace.name='example-ns-1', target.tag-namespace.name='example-ns-2'}
```

---

### Placeholders Used

Replace all placeholders before use:

- `<ONM_Compartment_OCID>`
- `<OKE_Cluster_Compartment_OCID>`
- `<OCI_Management_Agent_Dynamic_Group>`
- `<OKE_Instances_Dynamic_Group>`
- `<User_Group>`
- `<OKE_Compartment_OCID>`
- `<OKE_Cluster_OCID>`
- `<Compartment_OCID>`
- Defined tag namespaces (e.g., `'example-ns-1'`)

---

For more details, see Oracle documentation:
- [Managing Dynamic Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm)
- [Managing Users](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingusers.htm)
- [Managing User Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)
