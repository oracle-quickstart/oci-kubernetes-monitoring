# 1. Introduction
Automatic PrometheusEmitter collection is a feature that allows the Agent to automatically find and identify metrics emitting pods to monitor, eliminating the need to manually create the PrometheusEmitter configuration to collect metrics.

# 2. Identification types (in order)
## 2.1. prometheus scrape config json
User can provide their custom configuration in [prometheus-scrape-config.json](./prometheus-scrape-config.json)
This takes highest precedence and overrides other types.

### 2.1.1  Sample JSON with all supported elements (including optional)
```
[
    {
        "podMatcher":
        {
            "namespace": "pod_namespace",
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

### 2.1.2 First class members
| member | required | Description |
|--------|----------|-------------|
| podMatcher | yes | Elements used to match pods |
| config | no | Collection configuration for PrometheusEmitter data source of the matching pod. This is optional, if disable is set to `true` |
| disable | no | This is optional and defaults to `false`. If set to `true`, then podMatcher is used to restrict matching pods from collecting PrometheusEmitter metrics |

### 2.1.3 podMatcher
| member | required | type | Description |
|--------|----------|----- | ------------|
| namespace | yes | `string` | Pod's namespace |
| podNameRegex | yes | `string`  | Complete regular expression to match pod name |

### 2.1.4 config
| member | required | type | default | Description |
|--------|----------|----- | ------- | ----------- |
| path | yes | `string` | NA | Path on which metrics are being emitted, e.g. /metrics  |
| port | yes | `int` | NA | Port on which metrics are being emitted |
| namespace | no | `string` | pod_prometheus_emitters | OCI namespace to which metrics are pushed |
| allowMetrics | no | `string` | * | Comma separated metrics allowed to be collected. Defaults to *, which means all |
| compartmentId | no | `string` | Agent's compartmentId | Compartment to which metrics are pushed. If not provided, then metrics will be pushed to same compartment where agent is installed |
| scheduleMins | no | `int` | 1 | Minute interval at which metrics are collected |

## 2.2 Prometheus.io scrape annotation
If there's no custom scrape json configuration available for a Pod, then agent will look for the standardized
prometheus.io annotation to build the basic configuration.</br>
Other configurations than `path` and `port` are set to their default.

## 2.2.1 Sample Annotation
```
 annotations:
   prometheus.io/path: "/path/to/metrics"
   prometheus.io/port: "8080"
   prometheus.io/scrape: "true"
```
Agent will only scrape if `prometheus.io/scrape` is set to `true`.</br> 
The `prometheus.io/path` is optional, if not set, then it will default to `/metrics`.

## 2.3 Pod port specification
This is the fallback way, if none of the above configurations are defined. Here Agent looks for port spec with port name as `metrics` and port protocol as `TCP`.</br>
The path is set to default, i.e. `/metrics`. The rest of the configuration is set to default as well.