## FAQ

### Can I use kubectl do deploy the solution?

Helm is the recommended method of deployment. kubectl based deployment can be done by generating individual templates using helm. Refer [this](README.md#kubectl) for details.

### Can I use my own ServiceAccount ?

**Note**: This is supported only through the helm chart based deployment.

By default, a cluster role, cluster role binding and serviceaccount will be created for the Fluentd and Management Agent pods to access (readonly) various Kubernetes Objects within the cluster for supporting logs, objects and metrics collection. However, if you want to use your own serviceaccount, you can do the same by setting the "oci-onm-common.createServiceAccount" variable to false and providing your own serviceaccount in the "oci-onm-common.serviceAccount" variable. Ensure that the serviceaccount should be in the same namespace as the namespace used for the whole deployment. The namespace for the whole deployment can be set using the "oci-onm-common.namespace" variable, whose default value is "oci-onm".

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

### How to set encoding for logs ?

**Note**: This is supported only through the helm chart based deployment.

By default Fluentd tail plugin that is being used to collect various logs has default encoding set to ASCII-8BIT. To overrided the default encoding, use one of the following approaches.

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

The encoding can be set at invidivual log types like kubernetesSystem, linuxSystem, genericContainerLogs, which applies to all the logs under the specific log type.

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

### How to use Configfile based AuthZ (User Principal) instead of default AuthZ (Instance Principal) ?

**Note**: This is supported only through the helm chart based deployment.

The default AuthZ configuration for connecting to OCI Services from the monitoring pods running in the Kubernetes clusters is `InstancePrincipal` and it is the recommended approach for OKE. If you are trying to monitor Kubernetes clusters other than OKE, you need to use `config` file based AuthZ instead.

First you need to have a OCI local user (preferrably a dedicated user created only for this use-case so that you can restrict the policies accordingly) and OCI user group. Then you need to generate API Signing key and policies. 

  * Refer [OCI API Signing Key](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm) for instructions on how to generate API Signing key for a given user.
  * Refer [this](README.md#pre-requisites) for creating required policies.

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

### Enable Multi Process Workers

**Note**: This feature will not work with custom fluentd configuration and if you set custom fluentd configuration, it would be placed under worker 0.

To enable multi-process workers feature of Fluentd, set value of `multiProcessWorkers` under oci-onm-logan to the desired number of workers. By default it is set 0, indicating that the feature is disabled. To assign different workers for different logs, you may set `worker` field to the desired worker id against each of the individual logs or group of logs as supported in the confguration. The default worker id is set to 0 for all the logs when enabling `multiProcessWorkers` feature. The following are few examples,
 
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

### Log Collection for OCNE (Oracle Cloud Native Environment)

#### How to fix _execution expired_ error ?

Log location: `/var/log/oci-logging-analytics.log`

Sample Error :
```
E, [2023-08-07T10:17:13.710854 #18] ERROR -- : oci upload exception : Error while uploading the payload. { 'message': 'execution expired', 'status': 0, 'opc-request-id': 'D733ED0C244340748973D8A035068955', 'response-body': '' } 
```

* Check if your OCNE setup configuration has `restrict-service-externalip` value set to `true` for kubernetes module. If yes, update it to false to allow access to Logging Analytics endpoint from containers. Refer [this](https://docs.oracle.com/en/operating-systems/olcne/1.3/orchestration/external-ips.html#8.4-Enabling-Access-to-all-externalIPs) for more details. If the issue is still not resolved,
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

### Control plane log collection for AWS EKS (Amazon Elastic Kubernetes Service)

AWS EKS control plane logs are available in CloudWatch. 
Once the control plane log collection is enabled, the logs are directly pulled from CloudWatch and ingested into OCI Logging Analytics for further analysis. Alternatively, the logs can be routed over to S3 and pulled from there.

#### When should I use S3 collection mechanism over CloudWatch?
Pulling CloudWatch logs from S3 is an alternate option. You may want to use it in case of running into [CloudWatch service quotas](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch_limits_cwl.html) or if you are streaming logs over to S3 for any other reason.

#### How do I collect EKS control plane logs from CloudWatch?
To collect the logs from CloudWatch directly, modify your override_values.yaml to add the following and get the collection started.

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

#### How do I collect EKS control plane logs from S3?
If you prefer to collect logs from S3, please refer [EKS CP Logs Streaming to S3](./eks-cp-logs.md) for instructions on how to configure streaming of EKS Control Plane logs to AWS S3 and subsequenty collect them in OCI Logging Analytics. Once the streaming of logs is setup, modify your override_values.yaml to add the following and get the collection started.

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
