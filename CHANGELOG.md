# Change Log

## 2023-08-07
### Added
- Support Fluentd's [Multi Process Workers](https://docs.fluentd.org/deployment/multi-process-workers). 
- Custom Container Image for Fluentd using OL8-Slim as base Image.
- PV, PVC Objects Collection 
### Changed
- Instructions and dependency versions updates to custom container image for Fluentd using OL8 as base image.
- ClusterRole updates to add read permission for `storage.k8s.io` api group to support PV, PVC Objects collection. 
### Deprecating
- Custom Container Image for Fluentd using Debian and OL8 as base Image. 

## 2023-07-19
### Added
- Helm repo throguh Github pages.

## 2023-06-14
### Added
- Kubernetes Metrics Collection to OCI Monitoring using OCI Management Agent.
- Support for Kubernetes Service and EndpointSlice Object logs collection.
### Changed
- Refactoring of helm chart, terraform and stack/market place app to support the consolidation of logs, objects and metrics collection.
### Breaking Changes
- The refactoring work done in this version, may cause issues if you upgrade to this version (v3.0.0) from previous versions. Refer [here](README.md#2x-to-3x) for further details. 

## 2023-02-07
### Added
- Create a new mount (rw) using the value provided for baseDir.
- Expose "encoding" parameter of Fluentd's tail plugin as part of values.yaml, which allows users to override default encoding (ASCII-8BIT) for applicable logs/log types.
- Partial CRI logs handling.
- Oracle Resource Manager / Terraform support for deploying the solution.
### Changed
- Modified /var/log to mount as readonly by default, except when /var/log is set as baseDir (to store Fluentd state, buffer etc.,).
### Breaking Changes
- Logging Analytics Fluentd Output plugin log location will be derived using baseDir instead using value of fluentd:ociLoggingAnalyticsOutputPlugin:plugin_log_location. The default value still remains unchanged and is a non breaking change except if it was modified to a different value.

## 2022-08-30
### Added
- Helm chart templatisation/parameterisation to provide granular level control on the chart and its values.
- Support for custom ServiceAccount.
### Breaking Changes
- If you have not modified any of the templates values.yaml for any customisation including custom Fluentd configuration etc., then upgrading to this version is a non breaking change. In case, if you have any modifications or customisations, then you may need to adjust those according to the new templatisation format before upgrading to this version.

## 2022-07-13
### Added
- Collection support for StatefulSet, Job and CronJob objects.

## 2022-05-18
### Added
- Metrics support from OCI Logging Analytics Fluentd Output Plugin.
### Security
- fluent-plugin-kubernetes_metadata_filter version upgrade to 2.9.5 & fluent-plugin-kubernetes-objects version upgrade to 1.1.12, for kubeclient gem upgrade to ~4.9.3 containing security fixes.
### Breaking Changes
- fluent-plugin-kubernetes-objects upgrade has breaking changes w.r.t Fluentd configuration for Kubernetes Object Collection.

## 2022-04-20
### Added
- Pod Annotations based customiation of configuration paremeters (oci_la_log_source_name, oci_la_log_group_id, oci_la_entity_id) for logs collected through "Kubernetes Container Generic Logs".
- README update for custom configuration documentation.
- Flush interval and timeout label configuration for Concat plugin section.

## 2022-02-24
### Added
- Oracle Linux 8 based Docker Image support.
### Changed
- fluent-plugin-oci-logging-analytics version upgrade to 2.0.2 for memory usage improvements.
- Fluentd version upgrade to 1.14.3.

## 2022-02-7
### Added
- Helm chart v1.0.0 release.
### Fixed
- Fluentd config fix in CRI (configmap-cri.yaml) for Container Generic Logs.

## 2022-01-20
### Added
- Initial release.
