# Change Log

# 2025-08-07
### Added
- New feature 'Automatic Prometheus Collection' in Management Agent. This enables agent to automatically find and identify metrics emitting pods to monitor, eliminating the need to manually create the Prometheus configuration to collect metrics.

## Changed
- Management Agent container image has been updated to version 1.9.0

# 2025-06-17
### Added
- Introduced a new DaemonSet that uses eBPF (Extended Berkeley Packet Filter) to capture TCP connection logs and builds application/network topology representing workload to workload relationships within the Kubernetes cluster.
  - To be able to run the required eBPF program, the pods needs to run in privileged mode but restricting to CAP_BPF capability only.
- New helm variable to control the resource limits at individual logan workloads.
- Enables OKE infra discovery and service logs collection (default)
- OCI Console integration supporting new features:
  - Topology : New Views (Infra and Network) along with Platform.
  - View Insights for Workloads including capabilities to view the detailed spec of a workload, monitor the changes to the spec of a workload, create in-line labels for issues etc.

### Changed
- `kubernetesClusterID` (in the Helm chart) is now a mandatory field. *(This is not backward compatible.)*

## 2025-03-19
### Added
- OKE Infrastructure Discovery: Automatic detection of associated VCNs, subnets, and load balancers.
- OKE Infrastructure Logs Collection: Enables log collection for infrastructure components associated with the OKE cluster.
  - Disabled by default. Refer to the FAQs for steps to enable this feature.


## 2025-02-07
### Changed
- Management Agent container image has been updated to version 1.7.0

## 2025-02-03
### Changed
- Fluentd collector container image uptake to 1.5.3 having few gem updates related to vulnerability fixes.
  - Similar updates to build files (Dockerfile, Gemfile) that helps building custom container image.
### Removed
- Removed the deprecated folders (debian-deprecated, oraclelinux/8-deprecated) and corresponding build files from docker-images/v1.    

## 2024-11-20
### Added
- Support for new OCI Regions which are not yet supported through OCI Ruby SDK by default.
- Status check for OKE lifecycle state to be active before installing helm chart, when installed using RMS.
- An option to apply a static delay before installing helm chart, when installed using RMS.

## 2024-11-05
### Added
- Support of extraEnv for Management Agent
- Option to override hostPath permission for Management Agent DaemonSet deployment
### Changed
- Management Agent docker image has been updated to version 1.6.0
- Default metrics-server has been updated to version 0.7.2

## 2024-09-19
### Changed
- Fluentd collector container image uptake to 1.5.0 having OS update, Ruby 3.3.1 upgrade and other dependency gem updates.
  - Similar updates to build files (Dockerfile, Gemfile) that helps building custom container image.

## 2024-07-08
### Added
- Option to disable JRE default security property for Agent.
- Quick fix to support ImagePullSecrets for discovery job. 

## 2024-06-18
### Changed
- Fluentd collector container image uptake to 1.4.3 having OS and other dependency updates.
- Dockerfile (supporting custom container image builds) changes to remove patch version dependency on ruby 3.1 and related packages.

## 2024-05-13
### Changed
- Fluentd collector container image uptake to 1.4.2 having changes to uptake OCI 2.21.0. 
  - Similar updates to build files (Dockerfile, Gemfile) that helps building custom container image.

## 2024-04-29
### Added
- Support for Management Agent Daemonset deployment
### Changed
- Fluentd collector container image uptake to 1.4.1 having changes to uptake new OL8, ruby-default-gems versions. It also has changes to remove fluent-plugin-kubernetes-objects plugin dependency.
  - Similar updates to build files (Dockerfile, Gemfile) that helps building custom container image.
- Minor fixes to Documentation. 
- Minor fix to help `Kubelet logs` to use `Kubernetes Kubelet Logs` Log Source instead of `Linux System Logs` for Kubernetes versions above 1.25.   

## 2024-03-08
### Added
- Support for AWS EKS system and control plane logs collection.

## 2024-02-13
### Added
- Changes to support Kubernetes Solution Pages Offering by OCI Logging Analytics.
  - A new role and role binding in the monitoring namespace (which defaults to oci-onm), to manage a ConfigMap.
  - A new CronJob to handle the Kubernetes Objects discovery and Objects Logs collection using oci-logging-analytics-kubernetes-discovery Gem.
### Changed
- Moving forward, Kubernetes Objects logs would be collected using Kubernetes Discovery CronJob along with the (optional) Discovery data instead of Fluentd based Deployment.
## 2024-01-18
### Changed
- Management Agent docker image has been updated to version 1.2.0

## 2024-01-09
### Changed
- Concat filter plugin behavior changed to not include newline character as separator while handling CRI partial logs.
- Dashboards Import is now optional while installing the monitoring solution through RMS Stack. Default behavior remains the same.

## 2023-12-01
### Added
- Uptake ARM compatible container image from OCR for logan(Fluentd) chart.

## 2023-11-30
### Added
- Added resources information that got created through RM Stack to Stack output.
- Added new auto created policy for Kubernetes Objects discovery (for future release(s) use).
- Added new helm variable for cluster's EntityId (ociLAClusterEntityID) (for future release(s) use).
### Changed
- RM Stack is changed to use remote [helm repo](https://oracle-quickstart.github.io/oci-kubernetes-monitoring), instead of a local copy of helm chart source.
- RM Stack is modified to skip recreation of Management Agent Key if the Key already created by Stack.
### Breaking Changes
-  Removed ociLAEntityID input variable of Logan chart. This was an optional and its use-case was not defined so far. Hence, it shouldn't  be a breaking change in general but still documenting for the reference.

## 2023-11-07
### Added
- Control Plane Logs Collection for OCNE and Standalone Kubernetes Clusters.
- Support for launching Fluentd containers in privileged mode (default false).
- Added FAQ for triaging log collection setup issues in OCNE and Standalone Kubernetes Clusters.

## 2023-10-31
### Changed
- Ruby upgrade from 2.7.8 to 3.1.2 for OL8-Slim Fluentd container image. It also includes Fluentd (1.15.3 to 1.16.2) and other dependency gem upgrades.

## 2023-09-26
### Changed
- Ruby upgrade from 2.7.6 to 2.7.8 for OL8-Slim Fluentd container image.

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
