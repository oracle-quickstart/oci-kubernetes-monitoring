# oci-onm-mgmt-agent

![Version: 3.0.5](https://img.shields.io/badge/Version-3.0.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for collecting Kubernetes Metrics using OCI Management Agent into OCI Monitoring.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../common | oci-onm-common | 3.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| deployMetricServer | bool | `true` | By default, metric server will be deployed and used by Management Agent to collect metrics. You can set this to false if you already have metric server installed on your cluster |
| deployment.cleanupEpochTime | string | `nil` |  |
| deployment.daemonSet.hostPath | string | `nil` |  |
| deployment.daemonSet.overrideOwnership | bool | `true` |  |
| deployment.daemonSetDeployment | bool | `false` |  |
| deployment.resource.limit.cpuCore | string | `"500m"` |  |
| deployment.resource.limit.memory | string | `"1Gi"` |  |
| deployment.resource.request.cpuCore | string | `"200m"` |  |
| deployment.resource.request.memory | string | `"500Mi"` |  |
| deployment.resource.request.storage | string | `"2Gi"` |  |
| deployment.security.fsGroup | int | `2000` |  |
| deployment.security.runAsGroup | int | `2000` |  |
| deployment.security.runAsUser | int | `1000` |  |
| deployment.storageClass | string | `nil` |  |
| global.namespace | string | `"oci-onm"` | Kubernetes Namespace in which the resources to be created. Set oci-kubernetes-monitoring-common:createNamespace set to true, if the namespace doesn't exist. |
| global.resourceNamePrefix | string | `"oci-onm"` | Prefix to be attached to resources created through this chart. Not all resources may have this prefix. |
| kubernetesCluster.compartmentId | string | `nil` | OCI Compartment Id to push Kubernetes Monitoring metrics. If not specified default is same as Agent compartment |
| kubernetesCluster.enableAutomaticPrometheusDetection | bool | `false` |  |
| kubernetesCluster.monitoringNamespace | string | `nil` | OCI namespace to push Kubernetes Monitoring metrics. The namespace should match the pattern '^[a-z][a-z0-9_]*[a-z0-9]$'. By default metrics will be pushed to 'mgmtagent_kubernetes_metrics' |
| kubernetesCluster.name | string | `nil` | Kubernetes cluster name |
| kubernetesCluster.namespace | string | `"*"` | Kubernetes cluster namespace(s) to monitor. This can be a comma-separated list of namespaces or '*' to monitor all the namespaces |
| kubernetesCluster.overrideAllowMetricsAPIServer | string | `nil` | Provide the specific list of comma separated metric names for API server (/metrics) metrics to be collected. |
| kubernetesCluster.overrideAllowMetricsCluster | string | `nil` | Provide the specific list of comma separated metric names for agent computed metrics to be collected. |
| kubernetesCluster.overrideAllowMetricsKubelet | string | `nil` | Provide the specific list of comma separated metric names for Kubelet (/api/v1/nodes/<node_name>/proxy/metrics) metrics to be collected. |
| kubernetesCluster.overrideAllowMetricsNode | string | `nil` | Provide the specific list of comma separated metric names for Node (/api/v1/nodes/<node_name>/proxy/metrics/resource, /api/v1/nodes/<node_name>/proxy/metrics/cadvisor) metrics to be collected. |
| mgmtagent.extraEnv[0].name | string | `"DISABLE_JRE_DEFAULT_SECURITY_PROPERTIES_FILE"` |  |
| mgmtagent.extraEnv[0].value | string | `"false"` |  |
| mgmtagent.image.secret | string | `nil` | Image secrets to use for pulling container image (base64 encoded content of ~/.docker/config.json file) |
| mgmtagent.image.url | string | `nil` | Replace this value with actual docker image URL for Management Agent |
| mgmtagent.installKey | string | `"resources/input.rsp"` | Copy the downloaded Management Agent Install Key file under root helm directory as resources/input.rsp |
| mgmtagent.installKeyFileContent | string | `nil` | Provide the base64 encoded content of the Management Agent Install Key file (e.g. cat input.rsp | base64 -w 0) |
| namespace | string | `"{{ .Values.global.namespace }}"` | Kubernetes namespace to create and install this helm chart in |
| oci-onm-common.createNamespace | bool | `true` | If createNamespace is set to true, it tries to create the namespace defined in 'namespace' variable. |
| oci-onm-common.createServiceAccount | bool | `true` | By default, a cluster role, cluster role binding and serviceaccount will be created for the monitoring pods to be able to (readonly) access various objects within the cluster, to support collection of various telemetry data. You may set this to false and provide your own serviceaccount (in the parent chart(s)) which has the necessary cluster role(s) binded to it. Refer, README for the cluster role definition and other details. |
| oci-onm-common.namespace | string | `"{{ .Values.global.namespace }}"` | Kubernetes Namespace in which the serviceaccount to be created. |
| oci-onm-common.resourceNamePrefix | string | `"{{ .Values.global.resourceNamePrefix }}"` | Prefix to be attached to resources created through this chart. Not all resources may have this prefix. |
| oci-onm-common.serviceAccount | string | `"{{ .Values.global.resourceNamePrefix }}"` | Name of the Kubernetes ServiceAccount |
| serviceAccount | string | `"{{ .Values.global.resourceNamePrefix }}"` | Name of the Kubernetes ServiceAccount |
| tolerations | list | `[]` | Custom tolerations to apply to all pods in the chart. Default: [] (no additional tolerations) Example: tolerations:   - key: "example-taint"     operator: "Exists"     effect: "NoSchedule" |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
