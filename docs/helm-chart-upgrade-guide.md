
# OCI-ONM Helm Chart Upgrade Guide

This guide provides step-by-step instructions, version-specific changes, and important considerations for upgrading the `oci-onm` Helm chart.

> Important: Always test upgrades in a staging environment before applying them to production clusters.

## Upgrade: v3.6.0 → v4.0.0

### What's New


- TCP Connection Logging with eBPF:
  A new DaemonSet leverages eBPF (Extended Berkeley Packet Filter) to capture TCP connection logs, enabling enhanced visualization of application-level communication within your Kubernetes cluster.

- OCI Console Integration Enhancements:
  - Network View: Discover and visualize real-time communication between workloads in the cluster.
  - Infrastructure View: Visualize OKE infrastructure components such as subnets, load balancers, and nodes, and how they interact.
  - Kubernetes Spec Change Detection (View Insights): Track changes to over 50+ key properties across primary workload types:
    - DaemonSet
    - Deployment
    - ReplicaSet
    - StatefulSet
    - CronJob & Job

    Note: Managed workloads (e.g., a Job created by a CronJob) are excluded.

Additional features are available in the OCI Console beyond what’s listed here. Refer to the OCI Log Analytics Release Notes for more details.

## Upgrade Instructions


1. Update IAM Policies:
   - This version requires additional policy statements for infrastructure discovery.
     See the pre-requisites section in the [README](../README.md#0-pre-requisites) for details.

2. Create Logging Analytics Cluster Entity:
   - Follow [these steps](../README.md#1-create-logging-analytics-entity-of-type-kubernetes-cluster) to create a Kubernetes Cluster entity in Logging Analytics.
     Note: If this was already configured in earlier versions, no further action is required, you can upgrade your chart. (step 4)

3. Update your `values.yaml` file:

    ```yaml
    ...
    ...
    oci-onm-logan:
      ..
      ..
      ociLAClusterEntityID: <your-cluster-entity-ocid>
      ..
      ..
    ```

4. Upgrade the Helm chart:

    ```bash
    helm upgrade <release-name> oci/oci-onm -f values.yaml
    ```

## Post-upgrade Checklist

- [ ] Ensure `tcpconnect` DaemonSet pods are running (not in CrashLoopBackOff)
- [ ] Review logs of `tcpconnect` pods for any errors
- [ ] Review logs of `discovery` pods for any errors
- [ ] Verify that Network View and Application Topology are functional in the OCI Console

## Warnings & Considerations


- Disabling TCPConnect Logs:
  Setting `enableTCPConnectLogs: false` disables automatic discovery of workload communication, resulting in an empty topology view.

- Privileged Mode Required:
  The TCPConnect DaemonSet requires privileged mode to execute eBPF programs.

## Resources & Support

- Project Documentation: https://github.com/oracle-quickstart/oci-kubernetes-monitoring
- Report Issues on GitHub: https://github.com/oracle-quickstart/oci-kubernetes-monitoring/issues
