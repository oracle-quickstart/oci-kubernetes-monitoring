# oci-onm-logan

![Version: 3.0.0](https://img.shields.io/badge/Version-3.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.0.0](https://img.shields.io/badge/AppVersion-3.0.0-informational?style=flat-square)

Charts for sending Kubernetes platform logs, compute logs, and Kubernetes Objects information to OCI Logging Analytics.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | oci-onm-common | 3.0.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| authtype | string | `"InstancePrincipal"` | Allowed values: InstancePrincipal, config |
| extraEnv | list | `[]` | Logging Analytics OCID for OKE Cluster ociLAEntityID: Logging Analytics additional metadata. Use this to tag all the collected logs with one or more key:value pairs. Key must be a valid field in Logging Analytics metadata: "Client Host Region": "PCT" "Environment": "Production" "Third key": "Third Value" @param extra environment variables. Example   name: ENV_VARIABLE_NAME   value: ENV_VARIABLE_VALUE |
| extraVolumeMounts | list | `[]` | @param extraVolumeMounts Mount extra volume(s). Example:   - name: tmpDir     mountPath: /tmp |
| extraVolumes | list | `[]` | @param extraVolumes Extra volumes. Example:   - name: tmpDir     hostPath:         path: /tmp log |
| fluentd.baseDir | string | `"/var/log"` | Base directory on the node (with read write permission) for storing fluentd plugins related data. |
| fluentd.customFluentdConf | string | `""` |  |
| fluentd.customLogs | string | `nil` | Configuration for any custom logs which are not part of the default configuration defined in this file. All the pod/container logs will be collected as per "genericContainerLogs" section. Use this section to create a custom configuration for any of the container logs. Also, you can use this section to define configuration for any other log path existing on a Kubernetes worker node custom-id1: path: /var/log/containers/custom*.log Logging Analytics log source to use for parsing and processing the logs: ociLALogSourceName: "Custom1 Logs" The regular expression pattern for the starting line in case of multi-line logs. multilineStartRegExp: Set isContainerLog to false if the log is not a container log (/var/log/containers/*.log). Default value is true. isContainerLog: true |
| fluentd.file | string | `"fluent.conf"` | Fluentd config file name |
| fluentd.genericContainerLogs.exclude_path | list | `["\"/var/log/containers/kube-proxy-*.log\"","\"/var/log/containers/kube-flannel-*.log\"","\"/var/log/containers/kube-dns-autoscaler-*.log\"","\"/var/log/containers/coredns-*.log\"","\"/var/log/containers/csi-oci-node-*.log\"","\"/var/log/containers/proxymux-client-*.log\"","\"/var/log/containers/cluster-autoscaler-*.log\""]` | List of log paths to exclude that are already part of other specific configurations defined (like Kube Proxy, Kube Flannel) If you want to create a custom configuration for any of the container logs using the customLogs section, then exclude the corresponding log path here. |
| fluentd.genericContainerLogs.ociLALogSourceName | string | `"Kubernetes Container Generic Logs"` | Default Logging Analytics log source to use for parsing and processing the logs: Kubernetes Container Generic Logs. |
| fluentd.genericContainerLogs.path | string | `"/var/log/containers/*.log"` |  |
| fluentd.kubernetesMetadataFilter.ca_file | string | `nil` | Path to CA file for Kubernetes server certificate validation |
| fluentd.kubernetesMetadataFilter.kubernetes_url | string | `nil` | Kubernetes API server URL. Alternatively, environment variables KUBERNETES_SERVICE_HOST and KUBERNETES_SERVICE_PORT can be used Environment variable are given preference. |
| fluentd.kubernetesMetadataFilter.skip_container_metadata | bool | `false` | Skip the container fields container_image and container_image_id in the metadata. |
| fluentd.kubernetesMetadataFilter.skip_labels | bool | `false` | Skip all label fields from the metadata. |
| fluentd.kubernetesMetadataFilter.skip_master_url | bool | `false` | Skip the master_url field from the metadata. |
| fluentd.kubernetesMetadataFilter.skip_namespace_metadata | bool | `false` | Skip the namespace_id field from the metadata. The fetch_namespace_metadata function will be skipped. The plugin will be faster and cpu consumption will be less. |
| fluentd.kubernetesMetadataFilter.verify_ssl | bool | `true` | Validate SSL certificates |
| fluentd.kubernetesMetadataFilter.watch | bool | `true` | Set up a watch on the pods on the API server for updates to metadata. By default, true. |
| fluentd.kubernetesObjects | object | `{"objectsList":{"cron_jobs":{"api_endpoint":"apis/batch"},"daemon_sets":{"api_endpoint":"apis/apps"},"deployments":{"api_endpoint":"apis/apps"},"events":{"api_endpoint":""},"jobs":{"api_endpoint":"apis/batch"},"namespaces":{"api_endpoint":""},"nodes":{"api_endpoint":""},"pods":{"api_endpoint":""},"replica_sets":{"api_endpoint":"apis/apps"},"stateful_sets":{"api_endpoint":"apis/apps"}}}` | Configuration for collecting Kubernetes Object information. Supported objects are Node, Pod, Namespace, Event, DaemonSet, ReplicaSet, Deployment, StatefulSet, Job, CronJob |
| fluentd.kubernetesSystem.logs.cluster-autoscaler | object | `{"multilineStartRegExp":"/^\\S\\d{2}\\d{2}\\s+[^\\:]+:[^\\:]+:[^\\.]+\\.\\d{0,3}/","ociLALogSourceName":"Kubernetes Autoscaler Logs","path":"/var/log/containers/cluster-autoscaler-*.log"}` | Kubernetes Autoscaler Logs collection configuration |
| fluentd.kubernetesSystem.logs.coredns | object | `{"multilineStartRegExp":"/^\\[[^\\]]+\\]\\s+/","ociLALogSourceName":"Kubernetes Core DNS Logs","path":"/var/log/containers/coredns-*.log"}` | Kubernetes Core DNS Logs collection configuration |
| fluentd.kubernetesSystem.logs.csinode | object | `{"ociLALogSourceName":"Kubernetes CSI Node Driver Logs","path":"/var/log/containers/csi-oci-node-*.log"}` | Kubernetes CSI Node Driver Logs collection configuration |
| fluentd.kubernetesSystem.logs.kube-dns-autoscaler | object | `{"multilineStartRegExp":"/^\\S\\d{2}\\d{2}\\s+[^\\:]+:[^\\:]+:[^\\.]+\\.\\d{0,3}/","ociLALogSourceName":"Kubernetes DNS Autoscaler Logs","path":"/var/log/containers/kube-dns-autoscaler-*.log"}` | Kubernetes DNS Autoscaler Logs collection configuration |
| fluentd.kubernetesSystem.logs.kube-flannel | object | `{"multilineStartRegExp":"/^\\S\\d{2}\\d{2}\\s+[^\\:]+:[^\\:]+:[^\\.]+\\.\\d{0,3}/","ociLALogSourceName":"Kubernetes Flannel Logs","path":"/var/log/containers/kube-flannel-*.log"}` | Kube Flannel logs collection configuration |
| fluentd.kubernetesSystem.logs.kube-proxy | object | `{"multilineStartRegExp":"/^\\S\\d{2}\\d{2}\\s+[^\\:]+:[^\\:]+:[^\\.]+\\.\\d{0,3}/","ociLALogSourceName":"Kubernetes Proxy Logs","path":"/var/log/containers/kube-proxy-*.log"}` | Kube Proxy logs collection configuration |
| fluentd.kubernetesSystem.logs.proxymux | object | `{"ociLALogSourceName":"OKE Proxymux Client Logs","path":"/var/log/containers/proxymux-client-*.log"}` | Proxymux Client Logs collection configuration |
| fluentd.linuxSystem.logs.cronlog | object | `{"multilineStartRegExp":"/^(?:(?:\\d+\\s+)?<([^>]*)>(?:\\d+\\s+)?)?\\S+\\s+\\d{1,2}\\s+\\d{1,2}:\\d{1,2}:\\d{1,2}\\s+/","ociLALogSourceName":"Linux Cron Logs","path":"/var/log/cron*"}` | Linux CRON logs collection configuration |
| fluentd.linuxSystem.logs.kubeletlog | object | `{"ociLALogSourceName":"Kubernetes Kubelet Logs"}` | kubelet logs collection configuration |
| fluentd.linuxSystem.logs.linuxauditlog | object | `{"ociLALogSourceName":"Linux Audit Logs","path":"/var/log/audit/audit*"}` | Linux audit logs collection configuration |
| fluentd.linuxSystem.logs.maillog | object | `{"multilineStartRegExp":"/^(?:(?:\\d+\\s+)?<([^>]*)>(?:\\d+\\s+)?)?\\S+\\s+\\d{1,2}\\s+\\d{1,2}:\\d{1,2}:\\d{1,2}\\s+/","ociLALogSourceName":"Linux Mail Delivery Logs","path":"/var/log/maillog*"}` | Linux maillog collection configuration |
| fluentd.linuxSystem.logs.securelog | object | `{"multilineStartRegExp":"/^(?:(?:\\d+\\s+)?<([^>]*)>(?:\\d+\\s+)?)?\\S+\\s+\\d{1,2}\\s+\\d{1,2}:\\d{1,2}:\\d{1,2}\\s+/","ociLALogSourceName":"Linux Secure Logs","path":"/var/log/secure*"}` | Linux CRON logs collection configuration |
| fluentd.linuxSystem.logs.syslog | object | `{"multilineStartRegExp":"/^(?:(?:\\d+\\s+)?<([^>]*)>(?:\\d+\\s+)?)?\\S+\\s+\\d{1,2}\\s+\\d{1,2}:\\d{1,2}:\\d{1,2}\\s+/","ociLALogSourceName":"Linux Syslog Logs","path":"/var/log/messages*"}` | Linux syslog  collection configuration |
| fluentd.linuxSystem.logs.uptracklog | object | `{"multilineStartRegExp":"/^\\d{4}-\\d{2}-\\d{2}\\s+\\d{2}:\\d{2}:\\d{2}/","ociLALogSourceName":"Ksplice Logs","path":"/var/log/uptrack*"}` | Linux uptrack logs collection configuration |
| fluentd.linuxSystem.logs.yum | object | `{"ociLALogSourceName":"Linux YUM Logs","path":"/var/log/yum.log*"}` | Linux yum logs collection configuration |
| fluentd.ociLoggingAnalyticsOutputPlugin.buffer | object | `{"disable_chunk_backup":true,"flush_interval":30,"flush_thread_burst_interval":0.05,"flush_thread_count":1,"flush_thread_interval":0.5,"retry_exponential_backoff_base":2,"retry_forever":true,"retry_max_times":17,"retry_wait":2,"total_limit_size":"5368709120"}` | Fluentd Buffer Configuration |
| fluentd.ociLoggingAnalyticsOutputPlugin.plugin_log_file_count | int | `10` | The number of archived or rotated log files to keep, must be non-zero. |
| fluentd.ociLoggingAnalyticsOutputPlugin.plugin_log_file_size | string | `"10MB"` | The maximum log file size at which point the log file to be rotated, for example, 1KB, 1MB, etc. |
| fluentd.ociLoggingAnalyticsOutputPlugin.plugin_log_level | string | `"info"` | Output plugin logging level: DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN |
| fluentd.ociLoggingAnalyticsOutputPlugin.profile_name | string | `"DEFAULT"` | OCI API Key profile to use, if multiple profiles are found in the OCI API config file. |
| fluentd.path | string | `"/var/opt/conf"` | Path to the fluentd config file |
| fluentd.tailPlugin | object | `{"flushInterval":60,"readFromHead":true}` | Config for Logs Collection using fluentd tail plugin |
| global.namespace | string | `"oci-onm"` | Kubernetes Namespace for creating monitoring resources. Ignored if oci-kubernetes-monitoring-common.createNamespace set to false. |
| global.resourceNamePrefix | string | `"oci-onm"` | Resource names prefix used, where allowed. |
| image.imagePullPolicy | string | `"Always"` | Container image pull policy. |
| image.imagePullSecret | string | `nil` | Image pull secret name to use for pulling container image |
| image.url | string | `"container-registry.oracle.com/oci_observability_management/oci-la-fluentd-collector:1.0.0"` | Replace this value with actual docker image url |
| kubernetesClusterID | string | `nil` | OKE Cluster OCID e.g. ocid1.cluster.oc1.phx.aaaaaaaahhbadf3rxa62faaeixanvr7vftmkg6hupycbf4qszctf2wbmqqxq |
| kubernetesClusterName | string | `nil` | Kubernetes Cluster name. Need not be the OKE Cluster display name. e.g. production-cluster |
| namespace | string | `"{{ .Values.global.namespace }}"` | Kubernetes Namespace for deploying monitoring resources deployed by this chart. |
| objectsPollingFrequency | string | `"5m"` | Collection frequency (in minutes) for Kubernetes Objects |
| oci-onm-common.createNamespace | bool | `true` | Automatically create namespace for all resources (namespaced) used by OCI Kubernetes Monitoring Solution. |
| oci-onm-common.createServiceAccount | bool | `true` | Automatically create, a readonly cluster role, cluster role binding and serviceaccount is required # to read various cluster objects for monitoring. If set to false serviceaccount value must be provided in the parent chart. Refer, README for the cluster role definition and other details. |
| oci-onm-common.namespace | string | `"{{ .Values.global.namespace }}"` | Kubernetes Namespace for creating serviceaccount. Default: oci-onm |
| oci-onm-common.resourceNamePrefix | string | `"{{ .Values.global.resourceNamePrefix }}"` | Resoure Name Prefix: Wherever allowed, this prefix will be used with all resources used by this chart |
| oci-onm-common.serviceAccount | string | `"{{ .Values.global.resourceNamePrefix }}"` | Kubernetes ServiceAccount name |
| oci.configFiles."private.pem" | string | `""` | Private key file data   -----BEGIN RSA PRIVATE KEY-----   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   -----END RSA PRIVATE KEY----- |
| oci.configFiles.config | string | `"# Replace each of the below fields with actual values.\n[DEFAULT]\nuser=<user ocid>\nfingerprint=<fingerprint>\nkey_file=<key file path>\ntenancy=<tenancy ocid>\nregion=<region>"` | config file [data](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm) Replace each of the below fields with actual values.   [DEFAULT]   user=<user ocid>   fingerprint=<fingerprint>   key_file=<key file path>   tenancy=<tenancy ocid>   region=<region> |
| oci.file | string | `"config"` | Config file name |
| oci.path | string | `"/var/opt/.oci"` | Path to the OCI API config file |
| ociLALogGroupID | string | `nil` | OCID of Logging Analytics Log Group to send logs to. Can be overridden for individual log types. e.g. ocid1.loganalyticsloggroup.oc1.phx.amaaaaasdfaskriauucc55rlwlxe4ahe2vfmtuoqa6qsgu7mb6jugxacsk6a |
| ociLANamespace | string | `nil` |  |
| resourceNamePrefix | string | `"{{ .Values.global.resourceNamePrefix }}"` | Resoure Name Prefix: Wherever allowed, this prefix will be used with all resources used by this chart |
| resources.limits | object | `{"memory":"500Mi"}` | Limits |
| resources.requests | object | `{"cpu":"100m","memory":"250Mi"}` | Resource requests |
| runtime | string | `"cri"` | Container runtime for Kubernetes Cluster. Requires fluentd configuration changes accordingly Allowed values: docker, cri(for OKE 1.20 and above) |
| serviceAccount | string | `"{{ .Values.global.resourceNamePrefix }}"` | Kubernetes ServiceAccount |
| volumes | object | `{"containerdataHostPath":"/u01/data/docker/containers","podsHostPath":"/var/log/pods"}` | Log logvolumes for pod logs and container logs |
| volumes.containerdataHostPath | string | `"/u01/data/docker/containers"` | Path to the container data logs on Kubernetes Nodes |
| volumes.podsHostPath | string | `"/var/log/pods"` | Path to the pod logs on Kubernetes Nodes |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
