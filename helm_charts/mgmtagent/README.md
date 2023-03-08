<!--
# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
-->

# **OCI Management Agent Helm Chart**

## About

This provides an end-to-end monitoring solution for Kubernetes Clusters using Management Agent, Monitoring and other Oracle Cloud Infrastructure (OCI) Services. Following steps will walk you through the steps to configure Oracle Management Agent (Oracle provided data collector and Prometheus scraper) to collect various metrics from Kubernetes Cluster using package manager Helm.

*Note that installing this helm chart will deploy Management Agent [Statefulset](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) of replica one and Metric Server for collecting and pushing the metrics to OCI Monitoring.*

## Installation Instructions

### Pre-requisites

- Enable access to the OCI Monitoring to push metrics from Kubernetes environment:
    - Create a dynamic group Management_Agent_Dynamic_Group including relevant Management Agent resources from the required compartment. Refer [this](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm) for details about managing dynamic groups. This is the same Agent's compartment that you have used while creating the install key.
    ```
    ALL {resource.type='managementagent', resource.compartment.id='<compartment_id>'}
    ```
    - Add an IAM policy like, 
    ```
    ALLOW DYNAMIC-GROUP Management_Agent_Dynamic_Group TO USE METRICS IN COMPARTMENT <Agents_Compartment> where target.metrics.namespace = 'mgmtagent_kubernetes_metrics'
    ```
    This is the compartment where you want the Kubernetes metrics. This should match the compartmentId that you have specified in the values.yaml (kubernetesCluster:compartmentId)

- You need to create an install key for Management Agent installation before performing the helm deployment. Refer [this](https://docs.oracle.com/en-us/iaas/management-agents/doc/management-agents-administration-tasks.html#GUID-C841426A-2C32-4630-97B6-DF11F05D5712) for details on creating an install key.

- Build the Management Agent docker image to use it in your cluster. Refer [this](https://github.com/oracle/docker-images/tree/main/OracleManagementAgent) for details on building your docker image. 

- The docker image built from the above step, can either be pushed to Docker Hub or OCI Container Registry (OCIR) or to a Local Docker Registry depending on the requirements.
    - [How to push the image to Docker Hub](https://docs.docker.com/docker-hub/repos/#pushing-a-docker-container-image-to-docker-hub)
    - [How to push the image to OCIR](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/index.html).
    - [How to push the image to Local Registry](https://docs.docker.com/registry/deploying/).


- Install helm if not done already. Refer [this](https://helm.sh/docs/intro/install/) for instructions on installing helm.

- Download the helm chart. You can find the latest zip package under releases of this repo.

- Install OCI-CLI if not done already. Refer [this](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#Quickstart) for instructions on installing OCI-CLI. This is an optional step but is required if you want to visualize the metrics collected on Logging Analytics custom Dashboard. More about this in [Custom Kubernetes Monitoring Dashboard](#custom-kubernetes-monitoring-dashboard).

### Deploying Kuberenetes resources using Helm

#### values.yaml

In order to use the helm charts to deploy Management Agent, you need to collect the following information -

Name | Value 
--- | --- 
Kubernetes Cluster Name | The name of the Kubernetes cluster
Kubernetes Namespace | The names of the Kubernetes cluster namespaces to monitor
Management Agent Container Image URL | URL of the Management Agent container image used for the collection of the metrics.
Management Agent Install Key | input.rsp required for Management Agent registration. 
Compartment OCID | The OCID of the Compartment in which the metrics to be ingested.

- This file contains all the default values possible to setup the monitoring, but few values needs to be provided either through an external values.yaml file or by modifying this file. It is recommended to use external values.yaml to override any values.
- Inline documentation has the description and possible values for each of the configuration parameters.
- Value for `mgmtagent:installKey` is a relative path from root helm directory to install key file. Replace the empty input.rsp file in resources/input.rsp with the actual file. If you rename or change the path then update this value accordingly.
    ```shell
    $ cp ../input.rsp ./resources
    ```
- Value `mgmtagent:image:secret` is expected in base64 encoded format. These are the secrets used to pull docker image. Typically it is base64 encoded content of ~/.docker/config json file. You can encode it as:

    ```shell
    base64 ~/.docker/config 
    ```

#### Commands Reference

It is recommended to validate the values using the following `helm template` command before actually installing. 
If using external values.yaml, provide path to it helm-chart:

```shell
helm template --values <path-to-external-values.yaml> <path-to-helm-chart>
```
If using default values.yaml:
```shell
helm template <path-to-helm-chart>
```

Now, the chart can be installed using the following `helm install` command. Provide a desired release name, path to exterval values.yaml and path to helm-chart.

```shell
helm install <release-name> --values <path-to-external-values.yaml> <path-to-helm-chart>
```
Or, simply run
```shell
helm install <release-name> <path-to-helm-chart>
```

## Verify the Installation

Upon the successful installation of helm chart, following resources are created.

1. StatefulSet

    - The StatefulSet deployed as part of this installation is responsible for metrics collection.

    ```shell
    $ kubectl get statefulset -n=<namespace>

    NAME                  READY   AGE
    mgmtagent             1/1     5m40s
    ```

    ```shell
    $ kubectl get pods -l app=mgmtagent -n=<namespace>

    NAME             READY   STATUS    RESTARTS   AGE
    mgmtagent-0      1/1     Running   0          5m35s
    ```

2. Config Map

    - The config maps created as part of this installation contains management agent configuration for metrics collection.

    ```shell
    $ kubectl get configmaps -n=<namespace>

    NAME                               DATA   AGE
    mgmtagent-monitoring-config        1      5m
    ```

3. Verify Management Agent is running and emitting metrics
    ```shell
    $ kubectl exec -n=<namespace> --stdin --tty mgmtagent-0 -- tail -100 /opt/oracle/mgmt_agent/agent_inst/log/mgmt_agent_client.log | grep MetricUploadInvocation | grep rsp
    ```

    If you see similar messages like below, Management Agent is running and emitting metrics successfully.

    ```shell
    2022-09-27 17:47:43,490 [SendQueue.1 (SenderManager_sender)-53] INFO  - MetricUploadInvocation <--rsp[PVES5F4AOM4DCJORTH3/1102558CA937628CD/DF114CF84DFAE67218]<-- POST https://telemetry-ingestion.us-ashburn-1.oraclecloud.com/20180401/metrics: [200]
    ```

    > **Note**: If there is no output, rerun the command after a minute.


4. Agent pushes all Kubernetes specific metrics in `mgmtagent_kubernetes_metrics` Monitoring namespace under compartment you specified in values.yaml `kubernetesCluster:compartmentId`. You can use [OCI Monitoring](https://docs.oracle.com/en-us/iaas/Content/Monitoring/home.htm) console to view all these metrics and create alerts or build your own dashboards using [Logging Analytics](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/create-dashboards.html).

## Custom Kubernetes Monitoring Dashboard

Under resources we have a sample dashboard that helps the user visualize some of the cluster metrics that the agent emits. The sample dashboard is available as a json document.  Following are few editable fields in the provided JSON. The sample dashboard requires 2 values that need to be supplied by the user. Shared sample JSON has `<LOGGING_ANALYTICS_DASHBOARD_OCID>` and `<LOGGING_ANALYTICS_DASHBOARD_COMPARTMENT_OCID>`, make sure that you replace these 2 required values before executing the following command.

Name | Required | Value 
--- | --- | --- 
dashboardId | **Yes** |	OCID of the Logging Analytics Dashboard
compartmentId | **Yes** | OCID of the compartment. This is the compartment in which the dashboard has been created 
displayName	| No | The sample JSON includes a display name. This can be changed by the user
description | No | The user can modify this to add more description to the name.

*The user can create an empty dashboard in Logging Analytics so that it gets assigned an OCID.  This can be used with the sample dashboard provided to import. Refer [this](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/create-dashboards.html#GUID-9999AD67-96FE-4C15-B0E4-B1B40A4866F1) for more details on Logging Analytics Dashboard*

Once you have dashboard JSON ready you can use OCI CLI and execute the following command to create charts and visualize the metrics - 

```shell
$ oci management-dashboard dashboard import --from-json file:///scratch/helm-chart/mgmtagent_kubernetes_dashboard.json
````
Once the sample dashboard has been created, it will contain the visualization for some of the metrics that the agent is emitting. The user can always add more metric widgets to add visualizations for other metrics.

![Sample Dashboard](./resources/sample_mgmtagent_kubernetes_dashboard.png?raw=true "Kubernetes Monitoring Dashboard")

## Copyright
Copyright (c) 2022 Oracle and/or its affiliates.
