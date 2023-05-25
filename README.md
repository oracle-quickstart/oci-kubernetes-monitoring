# OCI Kubernetes Monitoring Solution

OCI Kubernetes Monitoring Solution is a turn-key Kubernetes monitoring and management package based on OCI Logging Analytics cloud service, OCI Monitoring, OCI Management Agent and Fluentd.

It enables DevOps, Cloud Admins, Developers, and Sysadmins to

* Continuously monitor health and performance
* Troubleshoot issues and identify their root causes
* Optimize IT environment based on long term data
* Identify configuration, and security issues

across their entire environment - using Logs, Metrics, and Object metadata.

It does extensive enrichment of logs, metrics and object information to enable cross correlation across entities from different tiers in OCI Logging Analytics. A collection of dashboards is provided to get users started quickly.

### Dashboards

![Kubernetes Cluster Summary Dashboard](logan/images/kubernetes-cluster-summary-dashboard.png)

<details>
  <summary>Expand for more dasshboard screenshots</summary>

![Kubernetes Nodes Dashboard](logan/images/kubernetes-nodes-dashboard.png)

![Kubernetes Workloads Dashboard](logan/images/kubernetes-workloads-dashboard.png)

![Kubernetes Pods Dashboard](logan/images/kubernetes-pods-dashboard.png)

</details>


# Get Started :rocket:

:stop_sign: Upgrading to a major version (like 2.x to 3.x)? See [upgrade](#upgrade) section below for details. :warning:

### Pre-requisites

* OCI Logging Analytics service must be onboarded in the OCI region where you want to monitor.
  * [Logging Analytics Quick Start](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/quick-start.html)
* OCI Dynamic Groups, Policies  (Details [here](TBD))

Multiple methods of installation are avialble, with following differences:

| Deployment Method | Supported Environments | Collection Automation | Dashboards | Customzations |
| ----| :----:| :----:| :---: | ---|
| Helm | All* | :heavy_check_mark:  | Manual| Full Control (Recommended)
| OCI Resource Manager | OKE | :heavy_check_mark:| :heavy_check_mark: | Partial Control
| Terraform | OKE | :heavy_check_mark: | :heavy_check_mark: | Partial Control
| kubectl | All* | Manual | Manual | Full Control (Not recommended)

\* For some environments, modification of the configuration may be required.

### Helm

#### 0 Pre-requisites

* Workstation or OCI Cloud Shell with access configured to the target k8s cluster.
* Helm ([Installation instructions](https://helm.sh/docs/intro/install/)).

#### 1 Download helm chart

* [latest](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/releases/latest/download/helm-chart.tgz)
* Go to [releases](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/releases) for a specific version.

#### 2 Update values.yaml

* Create override_values.yaml, to override the minimum required variables in values.yaml.
  - override_values.yaml
    ```
    global:
      # -- OCID for OKE cluster or a unique ID for other Kubernetes clusters.
      kubernetesClusterID:
      # -- Provide a unique name for the cluster. This would help in uniquely identifying the logs and metrics data at OCI Logging Analytics and OCI Monitoring respectively.
      kubernetesClusterName:

    oci-onm-logan:
      # Go to OCI Logging Analytics Administration, click Service Details, and note the namespace value.
      ociLANamespace:
      # OCI Logging Analytics Log Group OCID
      ociLALogGroupID:
    ```
* Refer to the oci-onm chart and sub-charts values.yaml for customising or modifying any other configuration. It is recommended to not modify the values.yaml provided with the charts, instead use override_values.yaml to achieve the same.    
  
#### 3.a Install helm release

Use the following `helm install` command to the install the chart. Provide a desired release name, path to override_values.yaml and path to helm chart.
```
helm install <release-name> --values <path-to-override-values.yaml> <path-to-helm-chart>
```
Refer [this](https://helm.sh/docs/helm/helm_install/) for further details on `helm install`.

#### 3.b Upgrade helm release

Use the following `helm upgrade` command if any further changes to override_values.yaml needs to be applied or a new chart version needs to be deployed. 
```
helm upgrade <release-name> --values <path-to-override-values.yaml> <path-to-helm-chart>
```
Refer [this](https://helm.sh/docs/helm/helm_upgrade/) for further details on `helm upgrade`.

#### 3.c Import Dashboards

Dashboards needs to be imported manually. Below is an example for importing Dashboards using OCI CLI.

1. Download and configure [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) or open cloud-shell where OCI CLI is pre-installed. Alternative methods like REST API, SDK, Terraform etc can also be used.
2. Find the **OCID** of the compartment, where the dashboards need to be imported.
3. Download the dashboard JSONs from [here](logan/terraform/oke/modules/dashboards/dashboards_json/) (TBD).
4. **Replace** all the instances of the keyword - "`${compartment_ocid}`" in the JSONs with the **Compartment OCID** identified in previous step.
    * Following command is for quick reference that can be used in a linux/cloud-shell envirnment :

        ```
        sed -i "s/\${compartment_ocid}/<Replace-with-Compartment-OCID>/g" *.json
        ```

5. Run the following commands to import the dashboards.

    ```
    oci management-dashboard dashboard import --from-json file://cluster.json
    oci management-dashboard dashboard import --from-json file://node.json
    oci management-dashboard dashboard import --from-json file://workload.json
    oci management-dashboard dashboard import --from-json file://pod.json
    ```

#### 4 Uninstall

Use the following `helm uninstall` command to uninstall the chart. Provide the release name used when creating the chart.
```
helm upgrade <release-name> --values <path-to-override-values.yaml> <path-to-helm-chart>
```
Refer [this](https://helm.sh/docs/helm/helm_uninstall/) for further details on `helm uninstall`.

### Option :one: OCI Resource Manager

Launch this OCI Resource Manager stack in OCI Tenancy Region of the OKE Cluster that you want to monitor

[![Deploy to Oracle Cloud][orm_button]][oci_kubernetes_monitoring_stack]

[oci_kubernetes_monitoring_stack]: https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/oci-kubernetes-monitoring/releases/latest/download/oci-kubernetes-monitoring-stack.zip

#### Upgrading fom 1.x or 2.x versions

## Getting Help

### [Ask a question](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/discussions/new?category=q-a)

## Resources

### :question: [Frequently Asked Questions](./docs/FAQ.md)

### [Custom Logs Configuration](./docs/Custom-logs.md)

### [Building Custom Container Images](./docs/customimages.md)

## License

Copyright (c) 2023, Oracle and/or its affiliates.
Licensed under the Universal Permissive License v1.0 as shown at <https://oss.oracle.com/licenses/upl>.

## [Contributors][def]

[def]: https://github.com/oracle-quickstart/oci-kubernetes-monitoring/graphs/contributors

[orm_button]: https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg
