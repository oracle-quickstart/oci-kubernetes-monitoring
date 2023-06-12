# Monitoring Solution for Kubernetes

## About

This provides an end-to-end monitoring solution for Oracle Container Engine for Kubernetes (OKE) and other forms of Kubernetes Clusters using Logging Analytics, Monitoring and other Oracle Cloud Infrastructure (OCI) Services.

![Kubernetes Cluster Summary Dashboard](logan/images/kubernetes-cluster-summary-dashboard.png)

![Kubernetes Nodes Dashboard](logan/images/kubernetes-nodes-dashboard.png)

![Kubernetes Workloads Dashboard](logan/images/kubernetes-workloads-dashboard.png)

![Kubernetes Pods Dashboard](logan/images/kubernetes-pods-dashboard.png)

## Logs

This solutions offers collection of various logs of a Kubernetes cluster into OCI Logging Analytics and offer rich analytics on top of the collected logs. Users may choose to customise the log collection by modifying the out of the box configuration that it provides.

### Kubernetes System/Service Logs

OKE or Kubernetes comes up with some built-in services where each one has different responsibilities and they run on one or more nodes in the cluster either as Deployments or DaemonSets.

The following service logs are configured to be collected out of the box:
- Kube Proxy
- Kube Flannel
- Kubelet
- CoreDNS
- CSI Node Driver
- DNS Autoscaler
- Cluster Autoscaler
- Proxymux Client

### Linux System Logs

The following Linux system logs are configured to be collected out of the box:
- Syslog
- Secure logs
- Cron logs
- Mail logs
- Audit logs
- Ksplice Uptrack logs
- Yum logs

### Control Plane Logs

The following are various Control Plane components in OKE/Kubernetes.
- Kube API Server
- Kube Scheduler
- Kube Controller Manager
- Cloud Controller Manager
- etcd

At present, control plane logs are not covered as part of out of the box collection, as these logs are not exposed to OKE customers.
The out of the box collection for these logs will be available soon for generic Kubernetes clusters and for OKE (when OKE makes these logs accessible to end users).

### Application Pod/Container Logs

All the logs from application pods writing STDOUT/STDERR are typically available under /var/log/containers/.
Application which are having custom log handlers (say log4j or similar) may route their logs differently but in general would be available on the node (through a volume).

## Kubernetes Objects

"Kubernetes objects are persistent entities in the Kubernetes system. Kubernetes uses these entities to represent the state of your cluster. Specifically, they can describe:
- What containerized applications are running (and on which nodes)
- The resources available to those applications
- The policies around how those applications behave, such as restart policies, upgrades, and fault-tolerance"

*Reference* : [Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)

The following are the list of objects supported at present:
- Nodes
- Namespaces
- Pods
- DaemonSets
- Deployments
- ReplicaSets
- Events

## Installation Instructions

### Deploy using Oracle Resource Manager

> **_NOTE:_** If you aren't already signed in, when prompted, enter the tenancy and user credentials. Review and accept the terms and conditions. If you aren't on-boarded to OCI Logging Analytics, refer to [Pre-requisites](#pre-requisites) section to enable Logging Analytics in the region where you want to deploy the stack. The default container image available through the deployment is only for demo/non-production use-cases, we recommend you to refer [Docker Image](#docker-image) section to build your own image.

- Click to deploy the stack

    [![Deploy to Oracle Cloud][orm_button]][oci_kubernetes_monitoring_stack]

- Select the region and compartment where you want to deploy the stack.

- Follow the on-screen prompts and instructions to create the stack.

- After creating the stack, click Terraform Actions, and select Plan.

- Wait for the job to be completed, and review the plan.

- To make any changes, return to the Stack Details page, click Edit Stack, and make the required changes. Then, run the Plan action again.

- If no further changes are necessary, return to the Stack Details page, click Terraform Actions, and select Apply.

### Pre-requisites

- Logging Analytics Service must be enabled in the given OCI region before trying out the following Solution. Refer [Logging Analytics Quick Start](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/quick-start.html) for details.
- Create a Logging Analytics LogGroup(s) if not have done already. Refer [Create Log Group](https://docs.oracle.com/en-us/iaas/logging-analytics/doc/create-logging-analytics-resources.html#GUID-D1758CFB-861F-420D-B12F-34D1CC5E3E0E).
- Enable access to the log group(s) to uploads logs from Kubernetes environment:
    - For InstancePrincipal based AuthZ (recommended for OKE and Kubernetes clusters running on OCI):
        - Create a dynamic group including relevant OCI Instances. Refer [this](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm) for details about managing dynamic groups.
        - Add an IAM policy like,
        ```
        Allow dynamic-group <dynamic_group_name> to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment <Logging Analytics LogGroup's compartment_name>
        ```
    - For Config file based (user principal) AuthZ:
        - Add an IAM policy like,
        ```
        Allow group <user_group_name> to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in compartment <Logging Analytics LogGroup's compartment_name>
        ```

### Docker Image

We are in the process of building a docker image based off Oracle Linux 8 including Fluentd, OCI Logging Analytics Output Plugin and all the required dependencies.
All the dependencies will be build from source and installed into the image. This image soon would be available to use as a pre-built image as is (OR) to create a custom image using this image as a base image.
At present, follow the below mentioned steps to build an image either using Dockerfile off Oracle Linux 8 as base image (OR) Dockerfile off Fluentd base image from Dockerhub (off Debian).
- Download all the files from one of the below mentioned dirs into a local machine having access to internet.
    - [OL8](logan/docker-images/v1.0/oraclelinux/8/)
	- [Debian](logan/docker-images/v1.0/debian/)
- Run the following command to build the docker image.
    - *docker build -t fluentd_oci_la -f Dockerfile .*
- The docker image built from the above step, can either be pushed to Docker Hub or OCI Container Registry (OCIR) or to a Local Docker Registry depending on the requirements.
    - [How to push the image to Docker Hub](https://docs.docker.com/docker-hub/repos/#pushing-a-docker-container-image-to-docker-hub)
    - [How to push the image to OCIR](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/index.html).
    - [How to push the image to Local Registry](https://docs.docker.com/registry/deploying/).

### Deploying Kuberenetes resources using Kubectl

#### Pre-requisites

- A machine having kubectl installed and setup to point to your Kubernetes environment.

#### To enable Logs collection

Download all the yaml files from [this dir](logan/kubernetes-resources/logs-collection/).
These yaml files needs to be applied using kubectl to create the necessary resources that enables the logs collection into Logging Analytics through a Fluentd based DaemonSet.

##### configmap-docker.yaml | configmap-cri.yaml

- This file contains the necessary out of the box fluentd configuration to collect Kubernetes System/Service Logs, Linux System Logs and Application Pod/Container Logs.
- Some log locations may differ for Kubernetes clusters other than OKE, EKS and may need modifications accordingly.
- Use configmap-docker.yaml for Kubernetes clusters based off Docker runtime (e.g., OKE < 1.20) and configmap-cri.yaml for Kubernetes clusters based off CRI-O.
- Inline comments are available in the file for each of the source/filter/match blocks for easy reference for making any changes to the configuration.
- Refer [this](https://docs.oracle.com/en/learn/oci_logging_analytics_fluentd/) to learn about each of the Logging Analytics Fluentd Output plugin configuration parameters.
- **Note**: A generic source with time only parser is defined/configured for collecting all application pod logs from /var/log/containers/ out of the box.
          It is recommended to define and use a LogSource/LogParser at Logging Analytics for a given log type and then modify the configuration accordingly.
          When adding a configuration (Source, Filter section) for any new container log, also exclude the log path from generic log collection,
            by adding the log path to *exclude_path* field in *in_tail_containerlogs* source block. This is to avoid the duplicate collection of logs through generic log collection.
            Refer [this](#custom-configuration) section for further details.

##### fluentd-daemonset.yaml

- This file has all the necessary resources required to deploy and run the Fluentd docker image as Daemonset.
- Inline comments are available in the file describing each of the fields/sections.
- Make sure to replace the fields with actual values before deploying.
- At minimum, <IMAGE_URL>, <OCI_LOGGING_ANALYTICS_LOG_GROUP_ID>, <OCI_TENANCY_NAMESPACE> needs to be updated.
- It is recommended to update <KUBERNETES_CLUSTER_OCID>,<KUBERNETES_CLUSTER_NAME> too, to tag all the logs processed with corresponding Kubernetes cluster at Logging Analytics.

##### secrets.yaml (Optional)

- At present, InstancePrincipal and OCI Config File (UserPrincipal) based Auth/AuthZ are supported for Fluentd to talk to OCI Logging Analytics APIs.
- We recommend to use InstancePrincipal based AuthZ for OKE and all clusters which are running on OCI VMs and that is the default auth type configured.
- Applying this file is not required when using InstancePrincipal based auth type.
- When config file based Authz is used, modify this file to fill out the values under config section with appropriate values.

##### Commands Reference

Apply the yaml files in the sequence of configmap-docker.yaml(or configmap-cri.yaml), secrets.yaml (not required for default auth type) and fluentd-daemonset.yaml.

```
$ kubectl apply -f configmap-docker.yaml
configmap/oci-la-fluentd-logs-configmap created

$ kubectl apply -f secrets.yaml
secret/oci-la-credentials-secret created

$ kubectl apply -f fluentd-daemonset.yaml
serviceaccount/oci-la-fluentd-serviceaccount created
clusterrole.rbac.authorization.k8s.io/oci-la-fluentd-logs-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/oci-la-fluentd-logs-clusterrolebinding created
daemonset.apps/oci-la-fluentd-daemonset created
```

Use the following command to restart DaemonSet after applying any modifications to configmap or secrets to reflect the changes into the Fluentd.

```
kubectl rollout restart daemonset oci-la-fluentd-daemonset -n=kube-system
```

#### To enable Kubernetes Objects collection

Download all the yaml files from [this dir](logan/kubernetes-resources/objects-collection/).
These yaml files needs to be applied using kubectl to create the necessary resources that enables the Kuberetes Objects collection into Logging Analytics.

##### configMap-objects.yaml

- This file contains the necessary out of the box fluentd configuration to collect Kubernetes Objects.
- Refer [this](https://docs.oracle.com/en/learn/oci_logging_analytics_fluentd/) to learn about each of the Logging Analytics Fluentd Output plugin configuration parameters.

##### fluentd-deployment.yaml

Refer [this](#fluentd-daemonsetyaml) section.

##### secrets.yaml (Optional)

Refer [this](#secretsyaml-optional) section.

##### Commands Reference

Apply the yaml files in the sequence of configmap-objects.yaml, secrets.yaml (not required for default auth type) and fluentd-deployment.yaml.

```
$ kubectl apply -f configmap-objects.yaml
configmap/oci-la-fluentd-objects-configmap configured

$ kubectl apply -f fluentd-deployment.yaml
serviceaccount/oci-la-fluentd-serviceaccount unchanged
clusterrole.rbac.authorization.k8s.io/oci-la-fluentd-objects-clusterrole created
clusterrolebinding.rbac.authorization.k8s.io/oci-la-fluentd-objects-clusterrolebinding created
deployment.apps/oci-la-fluentd-deployment created
```

Use the following command to restart Deployment after applying any modifications to configmap or secrets to reflect the changes into the Fluentd.

```
kubectl rollout restart deployment oci-la-fluentd-deployment -n=kube-system
```

### Deploying Kuberenetes resources using Helm

#### Pre-requisites

- Install helm if not done already. Refer [this](https://helm.sh/docs/intro/install/).
- Download the helm chart from [this dir](logan/helm-chart/).

#### values.yaml

- This file contains all the default values possible to setup the logs and objects collection, but few values needs to be provided either through an external values.yaml file or by modifying this file. It is recommended to use external values.yaml to override any values.
- Inline documentation has the description and possible values for each of the configuration parameters.
- At minimum, the following needs to be set accordingly. image:url, ociLANamespace, ociLALogGroupID. It is recommended to set kubernetesClusterID and kubernetesClusterName too, to tag all the logs processed with corresponding Kubernetes cluster at Logging Analytics.
- Use "docker" as runtime for Kubernetes clusters based off Docker runtime (e.g., OKE < 1.20) and "cri" for Kubernetes clusters based off CRI-O. The default is "cri".
- Use "InstancePrincipal" as authtype for OKE and all clusters which are running on OCI VMs and "config" as authtype for OCI Config file based Auth/AuthZ. config under oci section needs to be updated with relevant info when authtype is chosen as "config". The default is "InstancePrincipal".

#### Commands Reference

It is recommended to validate the values using the following `helm template` command before actually installing. Provide path to exterval values.yaml and path to helm-chart.

```
helm template --values <path-to-external-values.yaml> <path-to-helm-chart>
```

Now, the chart can be installed using the following `helm install` command. Provide a desired release name, path to exterval values.yaml and path to helm-chart.

```
helm install <release-name> --values <path-to-external-values.yaml> <path-to-helm-chart>
```

Use the following `helm upgrade` command if any further changes to values.yaml needs to be applied or a new chart version needs to be deployed. Refer [this](https://helm.sh/docs/helm/helm_upgrade/) for further details on `helm upgrade`.

```
helm upgrade <release-name> --values <path-to-external-values.yaml> <path-to-helm-chart>
```

Use the following `helm uninstall` command to delete the chart. Provide the release name used when creating the chart.

```
helm uninstall <release-name>
```

## Custom Configuration

### How to use custom logSource (oci_la_log_source_name) and/or other custom configuration for Pod/Container Logs collected through "Kubernetes Container Generic Logs" logSource ?

A generic source with time only parser is defined/configured for collecting all application pod logs from /var/log/containers/ out of the box.
This is to ensure that all the logs generated by all pods are collected and pushed to Logging Analytics.
Often you may need to configure a custom logSource for a particular pod log, either by using one of the existing OOB logSources at Logging Analytics or by defining one custom logSource matching to the requirements.
Once you have defined/identified a logSource for a particular pod log, the following are couple of ways to get those pod logs associated to the logSource.

#### Through Pod Annotations

In this approach, all that you need to do is add the following annotation, "oracle.com/oci_la_log_source_name" (with logSourceName as value) to all the pods of choice.
This approach works for all the use-cases, except for multi-line plain text formatted logs.

- Refer [this doc](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) to find how to add the annotation through Pod's metadata section. This is the recommended approach as it provides the persistent behavior.
- Refer [this doc](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#annotate) to find how to add annotation through 'kubectl annotate' command. You may use this approach for quick testing.

**Note** The following configuration parameters are supported for customisation through Pod Annotations in addition to logSource,
 - oracle.com/oci_la_log_group_id => to use custom logGroupId (oci_la_log_group_id)
 - oracle.com/oci_la_entity_id => to use custom entityId (oci_la_entity_id)

#### Through customLogs section

In this approach, all that you need to do is to provide the necessary configuration information like log file path, logSource, multiline start regular expression (in case of multi-line logs) in the customLogs section of values.yaml.
Using this information the corresponding Fluentd configuration is generated automatically.

**Note** This approach is valid only when using helm chart based installation.

The following example demonstrates a container customLogs configuration
```
      #custom-id1:
         #path: /var/log/containers/custom*.log
         #ociLALogSourceName: "Custom1 Logs"
         #multilineStartRegExp:
         # Set isContainerLog to false if the log is not a container log (/var/log/containers/*.log). Default value is true.
         #isContainerLog: true
```

The following example demonstrates a non container customLogs configuration
```
      #custom-id2:
         #path: /var/log/custom/*.log
         #ociLALogSourceName: "Custom2 Logs"
         #multilineStartRegExp:
         # Set isContainerLog to false if the log is not a container log (/var/log/containers/*.log). Default value is true.
         #isContainerLog: false
```

#### Through Custom Fluentd conf

In this approach, a new set of Source, Filter sections have to be created in the customFluentdConf section of values.yaml.
The following example demonstrates a custom fluentd config to tag /var/log/containers/frontend*.log with logSource "Guestbook Frontend Logs"
(*to be added to helm-chart values.yaml, under customFluentdConf section if using helm chart OR to either of configmap-cri.yaml / configmap-docker.yaml if using kubectl approach).

```
         <source>
            @type tail
            @id in_tail_frontend
            path_key tailed_path
            path /var/log/containers/frontend-*.log
            pos_file /var/log/oci_la_fluentd_outplugin/pos/frontend.logs.pos
            tag oci.oke.frontend.*
            read_from_head "#{ENV['FLUENT_OCI_READ_FROM_HEAD'] || true}"
            <parse>
            {{- if eq $runtime "docker" }}
            @type json
            {{- else}}
            @type cri
            {{- end }}
            </parse>
         </source>

         # Record transformer filter to apply Logging Analytics configuration to each record.
         <filter oci.oke.frontend.**>
            @type record_transformer
            enable_ruby true
            <record>
            oci_la_metadata ${{"{{"}}"Kubernetes Cluster Name": "#{ENV['FLUENT_OCI_KUBERNETES_CLUSTER_NAME'] || 'UNDEFINED'}", "Kubernetes Cluster ID": "#{ENV['FLUENT_OCI_KUBERNETES_CLUSTER_ID'] || 'UNDEFINED'}"{{"}}"}}
            oci_la_log_group_id "#{ENV['FLUENT_OCI_KUBERNETES_LOGGROUP_ID'] || ENV['FLUENT_OCI_DEFAULT_LOGGROUP_ID']}"
            oci_la_log_path "${record['tailed_path']}"
            oci_la_log_source_name "Guestbook Frontend Logs"
            {{- if eq $runtime "docker" }}
            message "${record['log']}"
            {{- end }}
            tag ${tag}
            </record>
         </filter>
```
**Note**: The log path */var/log/containers/frontend-*.log* has to be excluded from the generic container logs to avoid duplicate log collection. Add the log path to *exclude_path* value under *in_tail_containerlogs* source section.

In addition to the above, you may need to modify the source section to add *multiline* parser, if the logs are of plain text multi-line format (OR) add a concat plugin filter if the logs are of say multi-line but wrapped in json.
Refer OOB fluentd config in the helm-chart values.yaml for examples.


### How to use your own ServiceAccount ?

**Note**: This is supported only through the helm chart based deployment.

By default, a cluster role, cluster role binding and serviceaccount will be created for the Fluentd pods to access (readonly) various objects within the cluster for supporting logs and objects collection. However, if you want to use your own serviceaccount, you can do the same by setting the "createServiceAccount" variable to false and providing your own serviceaccount in the "serviceAccount" variable. Ensure that the serviceaccount should be in the same namespace as the namespace used for the whole deployment. The namespace for the whole deployment can be set using the "namespace" variable, whose default value is "kube-system".

The serviceaccount must be binded to a cluster role defined in your cluster, which allows access to various objects metadata. The following sample is a recommended minimalistic role definition as of chart version 2.0.0.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: oci-la-fluentd-generic-clusterrole
rules:
  - apiGroups:
      - ""
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - apps
      - batch
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
```

Once you have the cluster role defined, to bind the cluster role to your serviceaccount use the following cluster role binding definition.

```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: oci-la-fluentd-generic-clusterrolebinding
roleRef:
  kind: ClusterRole
  name: oci-la-fluentd-generic-clusterrole
  apiGroup: rbac.authorization.k8s.io
subjects:
  - kind: ServiceAccount
    name: <serviceaccount>
    namespace: <namespace>
```

### How to set encoding for logs ?

**Note**: This is supported only through the helm chart based deployment.

By default Fluentd tail plugin that is being used to collect various logs has default encoding set to ASCII-8BIT. To overrided the default encoding, use one of the following approaches.

#### Global level

Set value for encoding under fluentd:tailPlugin section of values.yaml, which applies to all the logs being collected from the cluster.

```
fluentd:
  ...
  ...
  tailPlugin:
    ...
    ...
    encoding: <ENCODING-VALUE>
```

#### Specific log type level

The encoding can be set at invidivual log types like kubernetesSystem, linuxSystem, genericContainerLogs, which applies to all the logs under the specific log type.

```
fluentd:
  ...
  ...
  kubernetesSystem:
    ...
    ...
    encoding: <ENCODING-VALUE>
```

```
fluentd:
  ...
  ...
  genericContainerLogs:
    ...
    ...
    encoding: <ENCODING-VALUE>
```

#### Specific log level

The encoding can be set at individual log level too, which takes precedence over all others.

```
fluentd:
  ...
  ...
  kubernetesSystem:
    ...
    ...
    logs:
      kube-proxy:
        encoding: <ENCODING-VALUE>
```

```
fluentd:
  ...
  ...
  customLogs:
      custom-log1:
        ...
        ...
        encoding: <ENCODING-VALUE>
      ...
      ...
```

## Importing Logging Analytics Kubernetes Dashboards

The Dashboards are imported as part of deploying the Kubernetes solution using [Oracle Resource Manager stack](#deploy-using-oracle-resource-manager). The following steps can be used to import the Dashboards manually to your tenancy.

1. Download and configure [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) or open cloud-shell where OCI CLI is pre-installed. Alternative methods like REST API, SDK, Terraform etc can also be used.
1. Find the **OCID** of compartment, where the dashboards need to be imported.
1. Download the dashboard JSONs from [here](logan/terraform/oke/modules/dashboards/dashboards_json/).
1. **Replace** all the instances of the keyword - "`${compartment_ocid}`" in the JSONs with the **Compartment OCID** identified in STEP 2.
    - Following are the set of commands for quick reference that can be used in a linux/cloud-shell envirnment :

        ```
        sed -i "s/\${compartment_ocid}/<Replace-with-Compartment-OCID>/g" file://cluster.json
        sed -i "s/\${compartment_ocid}/<Replace-with-Compartment-OCID>/g" file://node.json
        sed -i "s/\${compartment_ocid}/<Replace-with-Compartment-OCID>/g" file://workload.json
        sed -i "s/\${compartment_ocid}/<Replace-with-Compartment-OCID>/g" file://pod.json
        ```
1. Run the following commands to import the dashboards.

    ```
    oci management-dashboard dashboard import --from-json file://cluster.json
    oci management-dashboard dashboard import --from-json file://node.json
    oci management-dashboard dashboard import --from-json file://workload.json
    oci management-dashboard dashboard import --from-json file://pod.json
    ```

[orm_button]: https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg

[oci_kubernetes_monitoring_stack]: https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/oci-kubernetes-monitoring/releases/latest/download/oci-kubernetes-monitoring-stack.zip