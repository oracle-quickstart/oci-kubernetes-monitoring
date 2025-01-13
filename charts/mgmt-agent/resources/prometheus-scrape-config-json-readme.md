# prometheus-scrape-config.json

# Sample JSON with all elements (including optional)
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

# First class members
| member | required | Description |
|--------|----------|-------------|
| podMatcher | yes | Elements used to match pods |
| config | no | Collection configuration for PrometheusEmitter data source, of the matching pod. This is optional, if disable is set to `true` |
| disable | no | This is optional and defaults to `false`. If set to `true`, then podMatcher is used to restrict matching pods from collecting PrometheusEmitter metrics |

# podMatcher
| member | required | type | Description |
|--------|----------|----- | ------------|
| namespace | yes | `string` | Pod's namespace |
| podNameRegex | yes | `string`  | Complete regular expression to match pod name |

# config
| member | required | type | default | Description |
|--------|----------|----- | ------- | ----------- |
| path | yes | `string` | NA | Path on which metrics are being emitted. e.g. /metrics  |
| port | yes | `string` | NA | Complete regular expression to match pod name |
| namespace | no | `string` | pod_prometheus_emitters | OCI namespace to which metrics are pushed |
| allowMetrics | no | `string` | * | Comma separated metrics allowed to be collected. Defaults to *, which means all. |
| compartmentId | no | `string` | Agent's compartmentId | Compartment to which metrics are pushed. If not provided, then metrics will be pushed to same compartment where agent is installed |
| scheduleMins | no | `int` | 1 | Minute interval at which metrics are collected. |