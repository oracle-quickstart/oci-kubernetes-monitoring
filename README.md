# OCI Kubernetes Monitoring Solution v3.x

:stop_sign: Upgrading from previous versions? See upgrade section below.

## About

OCI Kubernetes Monitoring Solution is a turn-key Kubernetes monitoring and management package based on OCI Logging Analytics cloud service, OCI Monitoring, OCI Management Agent.

It enables DevOps, Cloud Admins, Developers, and Sysadmins to

* Continuously monitori health and performance
* Troubleshoot issues and identify their root causes
* Optimize IT environment based on long term data
* Identify configuration, and security issues

across their entire environment - using Logs, Metrics, and Object metadata - from:

* Cloud Infrastructure - Network, Load Balancers, Compute, Storage etc
* Kubernetes Platform - API Server, workers, network, ingress etc
* Applications - Pods, Services, Workloads, etc

It does extensive enrichment of logs, metrics and object information to enable cross correlation across entities from different tiers in OCI Logging Analytics. A collection of dashboards is provided to get users started quickly.


<details>
  <summary>Kubernetes Monitoring Dashboards</summary>

![Kubernetes Cluster Summary Dashboard](logan/images/kubernetes-cluster-summary-dashboard.png)

![Kubernetes Nodes Dashboard](logan/images/kubernetes-nodes-dashboard.png)

![Kubernetes Workloads Dashboard](logan/images/kubernetes-workloads-dashboard.png)

![Kubernetes Pods Dashboard](logan/images/kubernetes-pods-dashboard.png)

![Kubernetes Pods Dashboard](logan/images/kubernetes-pods-dashboard.png)

</details>
# Getting Started

### Pre-reqs

* OCI Logging Analytics service must be onboarded in the OCI region where you want to monitor.
  * [Logging Analytics Quick Start](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/quick-start.html)
* OCI Policies, Dynamic Groups (Details [here](TBD))

Multiple methods of installation are avialble, with following differences:

| Deployment Method | Collection Automation | Dashboards | Customzations |
| ----| :----:| :---: | ---|
| OCI Resource Manager | :heavy_check_mark:| :heavy_check_mark: | Highly opinionated (Recommended)
| Terraform | :heavy_check_mark: | :heavy_check_mark: | Full Control
| Helm Release | :heavy_check_mark:  | Manual| Full Control (Recommended for multiple enironments)
| kubectl | Manual | Manual | Full Control (Not recommended)

### Option 1: OCI Resource Manager

Launch this OCI Resource Manager stack in OCI Tenancy Region of the OKE Cluster that you want to monitor

[![Deploy to Oracle Cloud][orm_button]][oci_kubernetes_monitoring_stack]

[oci_kubernetes_monitoring_stack]: https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/oci-kubernetes-monitoring/releases/latest/download/oci-kubernetes-monitoring-stack.zip

### Option 2: Command Line for OKE Monitoring

#### 0 Pre-requisites

* Workstation or OCI Cloud Shell with access configured to target k8s cluster
* Helm ([Installation](https://helm.sh/docs/intro/install/)) (Learn more)

#### 1 Add helm repo

* add repo...

#### 2 Update values.yaml

* Logging Analytics Namespace - direct link to where to find
* Compartment
* Cluster-name

#### 3.a Install helm release

#### 3.b Import Dashboards

Dashboards must be imported manually. Below is an example of importing Dashboards using OCI CLI.

1. Download and configure [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) or open cloud-shell where OCI CLI is pre-installed. Alternative methods like REST API, SDK, Terraform etc can also be used.
2. Find the **OCID** of compartment, where the dashboards need to be imported.
3. Download the dashboard JSONs from [here](logan/terraform/oke/modules/dashboards/dashboards_json/).
4. **Replace** all the instances of the keyword - "`${compartment_ocid}`" in the JSONs with the **Compartment OCID** identified in STEP 2.
    * Following are the set of commands for quick reference that can be used in a linux/cloud-shell envirnment :

        ```
        sed -i "s/\${compartment_ocid}/<Replace-with-Compartment-OCID>/g" file://cluster.json
        sed -i "s/\${compartment_ocid}/<Replace-with-Compartment-OCID>/g" file://node.json
        sed -i "s/\${compartment_ocid}/<Replace-with-Compartment-OCID>/g" file://workload.json
        sed -i "s/\${compartment_ocid}/<Replace-with-Compartment-OCID>/g" file://pod.json
        ```

5. Run the following commands to import the dashboards.

    ```
    oci management-dashboard dashboard import --from-json file://cluster.json
    oci management-dashboard dashboard import --from-json file://node.json
    oci management-dashboard dashboard import --from-json file://workload.json
    oci management-dashboard dashboard import --from-json file://pod.json
    ```

[orm_button]: https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg

### Uninstall

* ..
* ..

### Upgrade

* ..
* ..

#### Upgrading fom 1.x or 2.x versions

## Getting Help

### [Ask a question](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/discussions/new?category=q-a)

## Resources

### [Frequently Asked Questions](./FAQ.md)

### [Custom Logs Configuration](./Custom-logs.md)

### [Building Custom Container Images](./customimages.md)

## License

Copyright (c) 2023, Oracle and/or its affiliates.
Licensed under the Universal Permissive License v1.0 as shown at <https://oss.oracle.com/licenses/upl>.

## [Contributors][def]

[def]: https://github.com/oracle-quickstart/oci-kubernetes-monitoring/graphs/contributors
