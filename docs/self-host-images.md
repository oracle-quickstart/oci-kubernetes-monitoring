# Runbook: no access to Oracle Container Registry

The `oci-onm` chart uses container images hosted in Oracle Container Registry. These images are publicly accessible over the internet.

Use this runbook when a cluster cannot, or is not allowed to, pull images from `container-registry.oracle.com`.

The default [Cluster Connect flow in OCI Kubernetes Monitoring](https://docs.oracle.com/iaas/log-analytics/doc/kubernetes-solution.html) automatically installs the Helm chart using its default images.

- If the cluster cannot access the internet, choose the **manual deployment** option.
  - The workflow provides the final Helm installation command for you to run.
- This guide shows how to use self-hosted images by modifying the final `oci-onm` Helm installation command.

## Issue

Check for image-pull failures:

```sh
kubectl get pods -n oci-onm
kubectl describe pod <pod-name> -n oci-onm
```

Affected pods can show `ErrImagePull` or `ImagePullBackOff`, with events similar to:

```text
Failed to pull image "container-registry.oracle.com/oci_observability_management/oci-la-fluentd-collector:1.7.5"
container-registry.oracle.com: Get "https://container-registry.oracle.com/v2/": dial tcp ...:443: i/o timeout
```

## Fix

1. Find the image URLs and tags for the chart version being installed in [`charts/oci-onm/values.yaml`](../charts/oci-onm/values.yaml).
2. **Self-host the required images.** Mirror the official images to a repository your cluster can access.
    - Use the correct tags (x.y.z) corresponding to chart version from [`charts/oci-onm/values.yaml`](../charts/oci-onm/values.yaml).

   | Component | Default image |
   | --- | --- |
   | Fluentd collector | `container-registry.oracle.com/oci_observability_management/oci-la-fluentd-collector:x.y.z` |
   | Management Agent | `container-registry.oracle.com/oci_observability_management/oci-management-agent:x.y.z` |

    > [!NOTE]
    > Any Kubernetes-compatible registry is supported. If you do not already have one, you can create one using [OCI Container Registry](https://docs.oracle.com/en-us/iaas/Content/Registry/Concepts/registryoverview.htm).

3. **Install metrics-server separately.** See the [metrics-server project](https://github.com/kubernetes-sigs/metrics-server) for installation instructions.

4. **Update the Helm installation.**

   - Add these parameters to the Helm command from Cluster Connect. This replaces the two `oci-onm` image URLs and disables the metrics-server included with the chart.

     ```sh
     --set oci-onm-logan.image.url=<self-hosted-fluentd-image-url> \
     --set oci-onm-mgmt-agent.mgmtagent.image.url=<self-hosted-management-agent-image-url> \
     --set oci-onm-mgmt-agent.deployMetricServer=false
     ```

   - Or add the following to the Helm values file, if you are using an external `values.yaml` file for installation:

     ```yaml
     oci-onm-logan:
       image:
         url: <self-hosted-fluentd-image-url>

     oci-onm-mgmt-agent:
       deployMetricServer: false
       mgmtagent:
         image:
           url: <self-hosted-management-agent-image-url>
     ```

## Verify

```sh
kubectl get pods -n oci-onm
```

Confirm that the collector and Management Agent pods are running.
