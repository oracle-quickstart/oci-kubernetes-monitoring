## FAQ

### What are the offerings of OCI Kubernetes Monitoring Solution ? 

OCI Kubernetes Monitoring Solution is a turn-key Kubernetes monitoring and management package based on OCI Log Analytics cloud service, OCI Monitoring, OCI Management Agent and Fluentd. It helps collecting various telemetry data (logs, metrics, Kubernetes objects state) from your Kubernetes cluster into OCI Log Analytics and OCI Monitoring). It also provides rich visual experiences using the collected information through Kubernetes Solution UX and pre-defined set of Dashboards. 

### What are the supported methods of installation ? 

Refer [here](../README.md#installation-instructions).

### In which namespace would the resources be installed on the Kubernetes cluster ?

`oci-onm` is the default namespace in which all the resources would be installed. However, there is a provision to choose a different namespace as required by overriding the `global.namespace` helm variable. You could also use an existing namespace by setting the namespace using `global.namespace` helm variable and overriding the `oci-onm-common.createNamespace` to `false`.  

### What resources would be created on the Kubernetes cluster ? 

| Resource | Scope | Default Name | Description | Additional Notes |
| :----: | :----: | :----: | :----: | :----: | 
| Namespace |	All |	oci-onm	| Namespace in which all the resources would be installed. | There is a provision to choose pre-created namespace or to create a different namespace and then use it. |
| DaemonSet	| Logs | oci-onm-logan | Responsible for log collection. | |
| DaemonSet	| Logs | oci-onm-logan-tcpconnect | Responsible for TCP connect logs collection aiding discovery of workload to workload relationships. | The pods in this DaemonSet run in privileged mode, but with only the CAP_BPF capability which enables the pods to run the required eBPF program. |
| CronJob	| Discovery, Kubernetes Objects State |	oci-onm-discovery |	Responsible for Kubernetes discovery and objects state collection. | |	
| StatefulSet |	Metrics	| oci-onm-mgmt-agent | Responsible for metrics collection. | |
| ConfigMap |	Logs | oci-onm-logs |	Contains Fluentd configuration aiding the log collection. | |	
| ConfigMap |	Discovery, Kubernetes Objects State |	oci-onm-discovery-state-tracker |	To track the Kubernetes discovery state. | |
| ServiceAccount | All | oci-onm | Service Account mapped to DaemonSet, StatefulSet and CronJob. |	There is a provision to provide an existing Service Account. |
| ClusterRole |	All |	oci-onm	| Contains pre-defined set of required rules/permissions at cluster level for the solution to work. |	There is a provision to use an existing cluster role/binding by binding it to the custom ServiceAccount. |
| ClusterRoleBinding | All | oci-onm | Binding between ClusterRole and ServiceAccount. | There is a provision to use an existing cluster role/binding by binding it to the custom ServiceAccount. | 
| Role | Discovery, Kubernetes Objects State | oci-onm | Contains pre-defined set of required rules/permissions at namespace level for the solution to work. |	|
| RoleBinding |	Discovery, Kubernetes Objects State |	oci-onm |	Binding between Role and ServiceAccount. | |
| Secret | Logs, Discovery, Kubernetes Objects State | oci-onm-oci-config |	To store OCI config credentials. | Created only when configFile based auth is chosen over the default instancePrincipal based auth. |
| Deployment | Logs |	oci-onm-logan	| Responsible for the collection of EKS control plane logs. | Created only when installing on EKS and setting `oci-onm-logan.enableEKSControlPlaneLogs` helm variable set to true. |
| ConfigMap |	Logs | oci-onm-ekscp-logs |	Contains Fluentd configuration aiding EKS control plane log collection. |	Created only when installing on EKS and setting `oci-onm-logan.enableEKSControlPlaneLogs` helm variable set to true. |
| Service |	Metrics |	oci-onm-mgmt-agent | Kubernetes Service for Mgmt Agent Pods. | |	
| ConfigMap |	Metrics |	oci-onm-metrics |	Configuration aiding Mgmt Agent Pods. | | 	
| PersistentVolume | Metrics | N/A | To aid persistent storage requirements of Mgmt Agent Pods. |	|
| PersistentVolumeClaim |	Metrics |	mgmtagent-pvc-oci-onm-mgmt-agent-0 | To aid persistent storage requirements of Mgmt Agent Pods. |	|

_Additionally, metrics-server and related resources would be installed to support the metrics collection. There is a provision to disable the metric service installation if it is already installed onto the cluster by overriding the `mgmt-agent.deployMetricServer` to `false`._

_Additionally, the following volumes of type hostPath would be created and mounted to specific pods._ 

| Volume | Volume Mount |	Type | Resource Scope |	Default Mount Path |	Default Host Path |	Description |	Additional Notes |
| :----: | :----: | :----: | :----: | :----: | :----: | :----: | :----: |
| varlog | varlog |	readOnly | oci-onm DaemonSet | /var/log |	/var/log | To access the pod logs on the node from /var/log/pods. | |	
| dockercontainerlogdirectory |	dockercontainerlogdirectory |	readOnly | oci-onm DaemonSet | /var/log/pods | /var/log/pods | To access the pod logs on the node from /var/log/pods. |	There is a provision to modify this if the logs are being written in a different directory. |
| dockercontainerdatadirectory | dockercontainerdatadirectory |	readOnly | oci-onm DaemonSet | /u01/data/docker/containers |	/u01/data/docker/containers |	To access the pod logs on the node from /var/log/pods linked to /u01/data/docker/containers. | There is a provision to modify this if the logs are being written in a different directory. |
| baseDir |	baseDir |	readwrite |	oci-onm DaemonSet, oci-onm Deployment |	/var/log | /var/log |	To store Fluentd buffer, and other information that helps tracking the state like tail plugin pos files. | There is a provision to use different dir than /var/log for this purpose as required by overriding the `oci-onm-logan.fluentd.baseDir` helm variable. | 

### What telemetry data is collected by the Solution ? 

#### Logs

The solutions offers collection of various logs of from the Kubernetes cluster into OCI Log Analytics and offer rich analytics on top of the collected logs. Users may choose to customise the log collection by modifying the out of the box configuration that it provides.

* Kubernetes System/Service Logs
    * The following logs are configured to be collected by default under this category. 
        * Kube Proxy
        * Kube Flannel
        * Kubelet
        * CoreDNS
        * CSI Node Driver
        * DNS Autoscaler
        * Cluster Autoscaler
        * Proxymux Client
* Linux System Logs
    * The following Linux system logs are configured to be collected by default.
        * Syslog
        * Secure logs
        * Cron logs
        * Mail logs
        * Audit logs
        * Ksplice Uptrack logs
        * Yum logs
* Pod/Container (Application) Logs
    * All the container logs available under `/var/log/containers/` on each worker nodes would be collected by default and processed using a generic Log Source named `Kubernetes Container Generic Logs`. However, users have ability to process different container logs using different Parsers/Sources at Log Analytics. Refer [this](#custom-logs.md) section to learn on how to perform the customisations. 

#### Metrics

The solution collects the following metrics by default.

* API Server metrics (using /metrics endpoint)
* Node/Kubelet metrics (using /api/v1/nodes/<node_name>/proxy/metrics/resource endpoint)
* cAdvisor metrics (using /api/v1/nodes/<node_name>/proxy/metrics/cadvisor endpoint)
* Few additional custom metrics computed at cluster level (like cpuUsage, memoryUsage)

#### Kubernetes Objects

"Kubernetes objects are persistent entities in the Kubernetes system. Kubernetes uses these entities to represent the state of your cluster. Specifically, they can describe:
  * What containerized applications are running (and on which nodes)
  * The resources available to those applications
  * The policies around how those applications behave, such as restart policies, upgrades, and fault-tolerance."

The following are the list of objects supported at present and stored in the form of logs.
  * Nodes
  * Namespaces
  * Pods
  * DaemonSets
  * Deployments
  * ReplicaSets
  * Jobs
  * CronJobs
  * Events
  * Services
  * EndpointSlices
  * PersistentVolumes
  * PersistentVolumeClaims

### What methods of Auth/AuthZ are supported ? 

The solution supports OCI Instance Principal and User Principal (OCI Config file) based Auth/AuthZ for logs and Kubernetes discovery data collection, and defaults to Instance Principal which is the recommended approach when deploying the solution on OKE. Refer [this](#how-to-use-configfile-based-authz-user-principal-instead-of-default-authz-instance-principal-) for the details on how to switch to configFile based Auth/AuthZ from the default Instance Principal based Auth/AuthZ. 

For metrics collection, it uses the OCI Resource Principal based Auth/AuthZ.

### Can I use my own ServiceAccount ?

By default, a cluster role, cluster role binding and serviceaccount will be created for the Fluentd and Management Agent pods to access (readonly) various Kubernetes Objects within the cluster for supporting logs, objects and metrics collection. However, if you want to use your own serviceaccount, you can do the same by setting the `oci-onm-common.createServiceAccount` variable to `false` and providing your own serviceaccount in the `oci-onm-common.serviceAccount` variable. Ensure that the serviceaccount is in the same namespace as the namespace used for the whole deployment. The namespace for the whole deployment can be set using the `oci-onm-common.namespace` variable, which defaults to `oci-onm`.

The serviceaccount must be binded to a cluster role defined in your cluster, which allows access to various objects metadata. The following sample is a recommended minimalistic role definition as of chart version 3.0.0.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: oci-onm
rules:
  - apiGroups:
      - ""
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - nonResourceURLs: ["/metrics"]
    verbs: ["get"]
  - apiGroups:
      - apps
      - batch
      - discovery.k8s.io
      - metrics.k8s.io
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
  name: oci-onm
roleRef:
  kind: ClusterRole
  name: oci-onm
  apiGroup: rbac.authorization.k8s.io
subjects:
  - kind: ServiceAccount
    name: <ServiceAccountName>
    namespace: <Namespace>
```

### How to customise resource names created by the solution ?

By default most of the Kubernetes resources created by the solution have prefix `oci-onm`. You may modify the same by overriding the helm variable, `global.resourceNamePrefix`.

### How to use custom container images ? 

Refer [this](custom-images.md) for instructions to build custom container images. 

Use the following helm variables to override the default Image location :

[`oci-onm-logan.image.url`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/oci-onm/values.yaml#L33)

[`oci-onm-mgmt-agent.mgmtagent.image.url`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/oci-onm/values.yaml#L55)

Optionally, you may set the ImagePullSecret to pull the images using the following helm variables :

[`oci-onm-logan.image.imagePullSecrets`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/logan/values.yaml#L49)

[`oci-onm-mgmt-agent.mgmtagent.image.secret`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/mgmt-agent/values.yaml#L34)

### How to customise the resource limits and requests for various monitoring pods ? 

By default pods deployed through `oci-onm-logan` daemonset and `oci-onm-discovery` cronjob (responsible for logs and discovery collection) are limited to `500Mi` memory with requests set to `250Mi` memory and `100m` cpu. While these default limits work for most of the moderate environments; depending on the environment, log volume and other relevant factors, these limits can be tuned. 

Use the helm variables under the following variable to override the defaults : 

[`oci-onm-logan.resources`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/logan/values.yaml#L96)

Similarly, you can modify the resource limits for pods deployed through oci-onm-mgmt-agent statefulset (responsible for metrics collection) using the following helm variables : 

[`oci-onm-mgmt-agent.deployment.resource`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/mgmt-agent/values.yaml#L84)

### How to modify the readwrite volume mount’s default hostPath ?

By default `/var/log` of underlying Kubernetes Node is mounted to `oci-onm-logan` daemonset pods in readwrite mode, to store Fluentd’s buffer and other relevant information that helps tracking the state like Fluentd tail plugin’s pos files etc. You can modify this to any other writable path on the node by using the following helm variable : 

[`oci-onm-logan.fluentd.baseDir`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/logan/values.yaml#L163)

### How to tune the various parameters that can effect logs collection, according to the log volume ? 

* Flush thread count
    * By default, Fluentd pods responsible for logs collection uses single flush thread. Though this works for most of the moderate log volumes, this can be tuned by using the following helm variable : 
        * [`oci-onm-logan.fluentd.ociLoggingAnalyticsOutputPlugin.buffer.flush_thread_count`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/logan/values.yaml#L183)
* Buffer size
    * By default, the solution uses Fluentd’s file buffer with size set to 5GB as default buffer size, which is used for buffering of chunks in-case of delays in sending the data to OCI Log Analytics and/or to handle outages at OCI without data loss. **We recommend** to modify/tune this to a size (to a higher or lower value) based on your environment and importance of data and other relevant factors. Use the following helm variable to modify the same : 
        * [`oci-onm-logan.fluentd.ociLoggingAnalyticsOutputPlugin.buffer.total_limit_size`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/logan/values.yaml#L186)
* Read from Head
    * By default, the solution tries to collect all the pod logs available on the nodes since beginning. Use the following helm variable to alter the behaviour if you wish to collect only new logs after the installation of the solution : 
        * [`oci-onm-logan.fluentd.tailPlugin.readFromHead`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/logan/values.yaml#L227)

### How to collect pod logs using custom OCI Log Analytics Source instead of using Kubernetes Container Generic Logs Source ?

Refer [here](custom-logs.md). 

### How to enable Fluentd’s multi-process worker configuration ?

We recommend tuning the default Fluentd configuration provided by this solution for clusters having high traffic/log volume. Often, you should be able to match the log collection throughput to incoming log volume by adjusting the flush thread count as mentioned [here](#how-to-tune-the-various-parameters-that-can-effect-logs-collection-according-to-the-log-volume-). However, if that is not sufficient, you can enable multi-process worker configuration to split the log collection across multiple fluentd processes where each process works against a set of logs. 

* First, enable the multi-process worker mode by setting the following helm variable to number of workers you intend to configure : 
    * [`oci-onm-logan.fluentd.multiProcessWorkers`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/logan/values.yaml#L166)
* Next you can configure the worker id, either at each of the individual log or log type level according to the need, by using the following helm variables : 
    * [`oci-onm-logan.fluentd.kubernetesSystem.worker`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/logan/values.yaml#L248) (to set at log type level, say for all KubernetesSystem logs)
    * [`oci-onm-logan.fluentd.kubernetesSystem.logs.kube-proxy.worker`](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/logan/values.yaml#L268) (to set at individual log level, say Kube Proxy logs)
* By default all logs would be mapped to `worker id 0` if not explicitly specified in multi-process worker mode.
* Following are few examples :

#### Example1  

Enable multi-process worker feature with 2 workers and set the worker id 1 to all container logs (except custom logs) and keeping the default worker id (0) for the remaining all logs. 

```      
..       
..       
oci-onm-logan:
  ..  
  ..  
  fluentd:
    ...   
    ...
    multiProcessWorkers: 2
    ...
    ...
    genericContainerLogs:
      ...
      ... 
      worker: 1
```       

#### Example2                 

Enable multi-process worker feature with 3 workers and set the worker id 1 to all container logs (except custom logs), worker id 2 to Kube Proxy, Linux Syslog and Kubelet logs, and keeping the default worker id (0) for the remaining all logs.    

```
..
..
oci-onm-logan:
  ..
  ..
  fluentd:
    ...
    ...
    multiProcessWorkers: 3
    ...
    ...
    kubernetesSystem:
    ...
    ...
      logs:
        ...
        ...
        kube-proxy:
          ...
          ...
          worker: 2
          ...
          ...
    ...
    ...
    linuxSystem:
      ...
      ...
      logs:
        ...
        ...
        syslog:
          ...
          ...
          worker: 2
          ...
          ...
    ...
    ...
    genericContainerLogs:
      ...
      ...
      worker: 1
```          

### Can I use kubectl to deploy the solution?

Helm is the recommended method of deployment. kubectl based deployment can be done by generating individual templates using helm. Refer [this](../README.md#kubectl) for details.

### How to set encoding for logs ?

**Note**: This is supported only through the helm chart based deployment.

By default Fluentd tail plugin that is being used to collect various logs has default encoding set to ASCII-8BIT. To override the default encoding, use one of the following approaches.

#### Global level

Set value for encoding under fluentd:tailPlugin section of values.yaml, which applies to all the logs being collected from the cluster.

```
..
..
oci-onm-logan:
  ..
  ..
  fluentd:
    ...
    ...
    tailPlugin:
      ...
      ...
      encoding: <ENCODING-VALUE>
```

#### Specific log type level

The encoding can be set at individual log types like kubernetesSystem, linuxSystem, genericContainerLogs, which applies to all the logs under the specific log type.

```
..
..
oci-onm-logan:
  ..
  ..
  fluentd:
    ...
    ...
    kubernetesSystem:
      ...
      ...
      encoding: <ENCODING-VALUE>
```

```
..
..
oci-onm-logan:
  ..
  ..
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
..
..
oci-onm-logan:
  ..
  ..
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
..
..
oci-onm-logan:
  ..
  ..
  fluentd:
    ...
    ...
    customLogs:
        custom-log1:
          ...
          ...
          encoding: <ENCODING-VALUE>
```

### How to set timezone override ?

If a log record contains a timezone identifier, the **Log Analytics service** will use that timezone. However, if there is no timezone information, the service defaults to **UTC**.

To override this default, use the `timezone` parameter in your `values.yaml` file. This parameter can be configured at different levels.

#### timezone override

**Note:** If a log record already has a timezone identifier, this setting may not be applicable.

* Setting `oci-onm-logan.fluentd.timezone` to **PST** applies PST as the default timezone for all logs collected via the Fluentd agent.
* Setting `oci-onm-logan.fluentd.genericContainerLogs.timezone` to **IST** applies IST as the default timezone specifically for generic container logs.


```
..
..
oci-onm-logan:
  fluentd:
    timezone: <Set default timezone for all logs collected via fluentd agent>
    ...
    ...
    
    kubernetesSystem:
      timezone: <Set default timezone for all Kubernetes System logs>
      logs:
        kube-proxy:
          timezone: <Set default timezone for kube-proxy logs>
        ...
        ...
    
    linuxSystem:
      logs:
        cronlog:
          timezone: <Set default timezone for cron logs>
        ...
        ...
    
    eksControlPlane:
      logs:
        apiserver:
          timezone: <Set default timezone for EKS API server logs>
        ...
        ...

    
    genericContainerLogs:
      timezone: <Set default timezone for generic container logs>
      ...
      ...
    
    customLogs:
      custom-log-1:
        timezone: <Set default timezone for custom logs>
        ...
        ...
```

### How to use Configfile based AuthZ (User Principal) instead of default AuthZ (Instance Principal) ?

**Note**: This is supported only through the helm chart based deployment.

The default AuthZ configuration for connecting to OCI Services from the monitoring pods running in the Kubernetes clusters is `InstancePrincipal` and it is the recommended approach for OKE. If you are trying to monitor Kubernetes clusters other than OKE, you need to use `config` file based AuthZ instead.

First you need to have a OCI local user (preferably a dedicated user created only for this use-case so that you can restrict the policies accordingly) and OCI user group. Then you need to generate API Signing key and policies. 

  * Refer [OCI API Signing Key](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm) for instructions on how to generate API Signing key for a given user.
  * Refer [this](../README.md#pre-requisites) for creating required policies.

#### Helm configuration

Modify your override_values.yaml to add the following. 

```
...
...
oci-onm-logan:
  ...
  ...
  authtype: config
  ## -- OCI API Key Based authentication details. Required when authtype set to config
  oci:
   # -- Path to the OCI API config file
   path: /var/opt/.oci
   # -- Config file name
   file: config
   configFiles:
      config: |-
         # Replace each of the below fields with actual values.
         [DEFAULT]
         user=<user ocid>
         fingerprint=<fingerprint>
         key_file=/var/opt/.oci/private.pem
         tenancy=<tenancy ocid>
         region=<region>
      private.pem: |-
      #   -----BEGIN RSA PRIVATE KEY-----
      #   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      #   -----END RSA PRIVATE KEY-----
``` 

### Log Collection for OCNE (Oracle Cloud Native Environment)

#### How to fix _execution expired_ error ?

Log location: `/var/log/oci-logging-analytics.log`

Sample Error :
```
E, [2023-08-07T10:17:13.710854 #18] ERROR -- : oci upload exception : Error while uploading the payload. { 'message': 'execution expired', 'status': 0, 'opc-request-id': 'D733ED0C244340748973D8A035068955', 'response-body': '' } 
```

* Check if your OCNE setup configuration has `restrict-service-externalip` value set to `true` for kubernetes module. If yes, update it to false to allow access to Log Analytics endpoint from containers. Refer [this](https://docs.oracle.com/en/operating-systems/olcne/1.3/orchestration/external-ips.html#8.4-Enabling-Access-to-all-externalIPs) for more details. If the issue is still not resolved,
  * Check if your OCNE setup configuration has `selinux` value set to `enforcing` in globals section. If yes, you may need to start the fluentd containers in privileged mode. To achieve the same, set `privileged` to true in override_values.yaml.

```
..
..
oci-onm-logan:
  ..
  ..
  privileged: true
```

#### How to fix _Permission denied @ dir_s_mkdir - /var/log/oci_la_fluentd_outplugin_ error ?

Log location: Pod logs of Daemonset `oci-onm-logan`

Set `privileged` to true in override_values.yaml to resolve this.

```
..
..
oci-onm-logan:
  ..
  ..
  privileged: true
```

### Log Collection for Standalone cluster (docker runtime)

#### How to fix the warning _/var/log/containers/..log unreadable_ ?

Log location: Pod logs of Daemonset `oci-onm-logan`

Sample Error:
```
2023-10-10 13:00:16 +0000 [warn]: #0 [in_tail_containerlogs] /var/log/containers/kube-flannel-ds-kl9bb_kube-flannel_kube-flannel-c2a954a05c57f4f68bc3ab348f071812be2405c76bd1631890638eac7c503506.log unreadable. It is excluded and would be examined next time.
```

The default path for docker data (in which the container logs will be written) in a typical standalone cluster is `/var/lib/docker/containers`. You may need to validate the same and update `containerdataHostPath` in override_values.yaml accordingly.

```
..
..
oci-onm-logan:
  ..
  ..
  volumes:
    ..
    containerdataHostPath: /var/lib/docker/containers
```

### OKE control plane and related infra components service logs collection

#### How to enable OKE infra discovery and corresponding infra services log collection

To enable the service logs (OKE control plane, load balancer and subnet flow logs) collection, set following helm variable to `true`.
**In addition to the below configuration change, you must create the required policies as mentioned under** [prerequisite](/README.md#pre-requisites) **section in readme.**

```yaml
oci-onm-logan:
  ..
  ..
  k8sDiscovery:
  ..
  ..
    infra:
      ..
      .. 
      enable_service_log: true
      .. 
      .. 
```

#### How to enable the discovery of node subnet and associated flow logs, when node pool subnet's compartment is different than OKE's compartment ?

By default, the discovery job only collects information from node pools that are in the same compartment as the OKE cluster. 

To enable node pool discovery across all compartments in the tenancy, customers can set the following properties in the Helm chart:

```yaml
oci-onm-logan:
  ..
  ..
  k8sDiscovery:
  ..
  ..
    infra:
      ..
      .. 
      probe_all_compartments: true
      tenancy_ocid: <TENANT_OCID>
      .. 
      .. 
```

##### Policies Required

In addition to the configuration changes mentioned above, the following policies must be modified (if you have opted for the policy creation during the initial setup) or added either at tenancy level or for all relevant compartments in the scope.

```plaintext
Allow dynamic-group ${OKE_DYNAMIC_GROUP} to inspect compartments in tenancy
Allow dynamic-group ${OKE_DYNAMIC_GROUP} to read cluster-node-pools in tenancy
Allow dynamic-group ${OKE_DYNAMIC_GROUP} to inspect subnets in tenancy
Allow dynamic-group ${OKE_DYNAMIC_GROUP} to {SUBNET_UPDATE} in tenancy
Allow dynamic-group ${OKE_DYNAMIC_GROUP} to use log-groups in tenancy
Allow dynamic-group ${OKE_DYNAMIC_GROUP} to read log-content in tenancy
Allow service loganalytics to {VCN_READ,SUBNET_READ,VNIC_READ} in tenancy
```

### Why does the TcpConnect DaemonSet use privileged mode? Can it be disabled?

TcpConnect DaemonSet is responsible for TCP connect logs collection aiding discovery of workload to workload relationships.

To be able to run the required eBPF program, the pods needs to run in privileged mode but restricting to CAP_BPF capability only.

If you need to disable this feature, set the following property to false:

> Note: Disabling this will prevent automatic discovery of workload-to-workload communication within the cluster, resulting in an empty network topology view in the OCI Console.

```yaml
...
...
oci-onm-logan:
  ..
  ..
  enableTCPConnectLogs: false
  ..
  ..
```

### Control plane log collection for AWS EKS (Amazon Elastic Kubernetes Service)

AWS EKS control plane logs are available in CloudWatch. 
Once the control plane log collection is enabled, the logs are directly pulled from CloudWatch and ingested into OCI Log Analytics for further analysis. Alternatively, the logs can be routed over to S3 and pulled from there.

#### How to collect EKS control plane logs from CloudWatch?
To collect the logs from CloudWatch directly, modify your override_values.yaml to add the following EKS specific variables. Various other variables are available in the values.yaml file and can be updated as necessary.

```      
..       
..       
oci-onm-logan:
  ..  
  ..
  enableEKSControlPlaneLogs: true  
  fluentd:
    ...   
    ...
    eksControlPlane:
      region:<aws_region>
      awsStsRoleArn:<role_arn>
```

#### How to collect EKS control plane logs from S3?
If you run into [CloudWatch service quotas](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch_limits_cwl.html), you can alternatively route the logs to S3 and collect them. The control plane logs in S3 need to be in a specific format for the default log collection to work. Please refer [EKS CP Logs Streaming to S3](./eks-cp-logs.md) for instructions on how to configure streaming of Control Plane logs to S3 and subsequently collect them in OCI Log Analytics. Once the streaming of logs is setup, modify your override_values.yaml to add the following EKS specific variables. Various other variables are available in the values.yaml file and can be updated as necessary.

```      
..       
..       
oci-onm-logan:
  ..  
  ..
  enableEKSControlPlaneLogs: true  
  fluentd:
    ...   
    ...
    eksControlPlane:
      collectionType:"s3"
      region:<aws_region>
      awsStsRoleArn:<role_arn>
      s3Bucket:<s3_bucket>
```