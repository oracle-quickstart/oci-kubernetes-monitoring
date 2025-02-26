# 1. Introduction
Automatic Prometheus collection is a feature that allows the Agent to automatically find and identify metrics emitting pods to monitor, eliminating the need to manually create the Prometheus configuration to collect metrics.

# 2. Identification of metric collection configuration

## 2.1 Out of the box
Management Agent has capabilities to detect metrics emitting pods, without making any custom configuration changes.

### 2.1.1 Pod' ports specification
Management Agent will look for pod port spec with port name as `metrics` and port protocol as `TCP`.</br>
Once found, the configuration is build using default path as `/metrics`. The rest of the configuration is set to default as well.

### 2.1.2 Prometheus.io Annotation
Deployments using industry standard prometheus.io annotations to enable scrapping, will be automatically detected out of the box by agent.</br>
The pod's ports specification configuration can be modified using the standardized prometheus.io annotations.</br>

### Sample annotation
```
 annotations:
   prometheus.io/path: "/path/to/metrics"
   prometheus.io/port: "8080"
   prometheus.io/scrape: "true"
```
Agent will only scrape if `prometheus.io/scrape` is set to `true`.</br> 
The `prometheus.io/path` is optional, if not set, then it will default to `/metrics`. The rest of the configuration is set to default as well.

## 2.2. prometheus scrape config json
The configuration can be fine tuned by providing custom json in [prometheus-scrape-config.json](./prometheus-scrape-config.json). This exposes all available PrometheusEmitter parameters.</br>
Json takes highest precedence and overrides other types (annotation and out of the box)</br>
If a pod matches multiple configs, then the last matching config will be applied.

### 2.2.1  Sample JSON with all supported parameters (including optional)
```
[
    {
        "podMatcher":
        {
            "namespaceRegex": "pod_namespace.*",
            "podNameRegex": "sample-pod.*"
        },
        "config":
        {
            "path": "/path/to/metrics/endpoint",
            "port": 9100,
            "namespace": "push_metrics_to_namespace",
            "allowMetrics": "sampleMetric1,sampleMetric2",
            "compartmentId": "ocid1.compartment.oc1..sample",
            "scheduleMins": 1
        },
        "disable": false
    },
    ...
]
```

### 2.2.2 First class members
| member | required | description |
|--------|----------|-------------|
| podMatcher | yes | Elements used to match pods |
| config | no | Collection configuration for PrometheusEmitter data source of the matching pod. This is optional, if disable is set to `true` |
| disable | no | This is optional and defaults to `false`. If set to `true`, then podMatcher is used to restrict matching pods from collecting PrometheusEmitter metrics |

### 2.2.3 podMatcher
| member | required | type | description |
|--------|----------|----- | ------------|
| namespaceRegex | yes | `string` | Complete regular expression to match pod's namespace |
| podNameRegex | yes | `string`  | Complete regular expression to match pod's name |

### 2.2.4 config
| member | required | type | default | description |
|--------|----------|----- | ------- | ----------- |
| path | no | `string` | /metrics | Path on which metrics are being emitted, e.g. /metrics  |
| port | yes | `int` | NA | Port on which metrics are being emitted |
| namespace | no | `string` | pod_prometheus_emitters | OCI namespace to which metrics are pushed |
| allowMetrics | no | `string` | * | Comma separated metrics allowed to be collected. Defaults to *, which means all |
| compartmentId | no | `string` | Agent's compartmentId | Compartment to which metrics are pushed. If not provided, then metrics will be pushed to same compartment where agent is installed |
| scheduleMins | no | `int` | 1 | Minute interval at which metrics are collected |
