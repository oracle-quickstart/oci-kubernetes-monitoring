# Use self-hosted collector images

The `oci-onm` Helm chart normally pulls the Fluentd collector and Oracle Management Agent images from Oracle Container Registry. If an OKE cluster cannot pull those public images—for example, because the environment is FIPS-enabled or the cluster has restricted outbound network access—mirror both images to a registry that the cluster can reach before installing the chart.

This guide explains how to configure the chart after the published images have been copied to a registry accessible to the cluster. It does not require rebuilding the images.

## Main steps

1. Create a repository in your tenancy's Container Registry.
2. Mirror the Fluentd collector and Management Agent images into your repository.
3. Install metrics-server on the OKE cluster outside the `oci-onm` chart.
4. Update the Cluster Connect values file or `--set` arguments with the self-hosted image URLs, and set `oci-onm-mgmt-agent.deployMetricServer=false`.
5. Install the `oci-onm` Helm chart.

## Recognize an image-pull failure

During or after the Helm installation, check the `oci-onm` namespace:

```sh
kubectl get pods -n oci-onm
```

An affected cluster typically shows Fluentd, discovery, or Management Agent pods in `ErrImagePull` or `ImagePullBackOff` status, rather than `Running`. Confirm the cause by describing one of the affected pods:

```sh
kubectl describe pod <pod-name> -n oci-onm
```

The events can show a failure to pull an Oracle image, such as the following registry connectivity timeout:

```text
Failed to pull image "container-registry.oracle.com/oci_observability_management/oci-la-fluentd-collector:1.7.5":
rpc error: code = DeadlineExceeded desc = unable to pull image: initializing source
docker://container-registry.oracle.com/...: pinging container registry
container-registry.oracle.com: Get "https://container-registry.oracle.com/v2/": dial tcp ...:443: i/o timeout
```

This indicates that the worker node cannot reach Oracle Container Registry. Mirror the images and configure the chart to use the mirrored locations as described below. An image-pull failure can also be caused by missing registry credentials; configure the pull credentials described in [Override the chart images](#override-the-chart-images) when the target registry is private.

## Before you begin

Perform the image copy from a workstation or build system that can reach both the Oracle source registry and your target registry. Ensure that OKE worker nodes can reach the target registry and have permission to pull from it.

The image versions below match the defaults in [`charts/oci-onm/values.yaml`](../charts/oci-onm/values.yaml). Customers must mirror the image tags used by the chart version they install. For the latest chart, use the image versions in [`charts/oci-onm/values.yaml` on the default branch](https://github.com/oracle-quickstart/oci-kubernetes-monitoring/blob/main/charts/oci-onm/values.yaml). Do not assume that the tags in this guide remain unchanged when installing a newer chart version.

| Component | Source image |
| --- | --- |
| Fluentd collector | `container-registry.oracle.com/oci_observability_management/oci-la-fluentd-collector:1.7.5` |
| Management Agent | `container-registry.oracle.com/oci_observability_management/oci-management-agent:1.13.0` |

Create target repositories in a registry that OKE worker nodes can reach. Keep the same repository paths as the source images:

- `oci_observability_management/oci-la-fluentd-collector`
- `oci_observability_management/oci-management-agent`

For information about creating and managing an OCI Container Registry repository, see Oracle's [Container Registry overview](https://docs.oracle.com/en-us/iaas/Content/Registry/Concepts/registryoverview.htm).

For OCIR instructions, see Oracle's OKE documentation for [pulling images from Container Registry during deployment](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengpullingimagesfromocir.htm).

## Self-hosted image URL examples

An OCIR image URL has the following form:

```text
ocir.<region-identifier>.oci.oraclecloud.com/<tenancy-namespace>/<repository-path>:<tag>
```

For example, for a registry in `us-ashburn-1` and a tenancy namespace of `ansh81vru1zp`, use the following self-hosted image URLs:

| Component | Self-hosted image URL |
| --- | --- |
| Fluentd collector | `ocir.us-ashburn-1.oci.oraclecloud.com/ansh81vru1zp/oci_observability_management/oci-la-fluentd-collector:1.7.5` |
| Management Agent | `ocir.us-ashburn-1.oci.oraclecloud.com/ansh81vru1zp/oci_observability_management/oci-management-agent:1.13.0` |

Replace `us-ashburn-1` and `ansh81vru1zp` with the region identifier and tenancy namespace for your registry.

## Install metrics-server separately

Before installing `oci-onm`, install a supported metrics-server deployment outside this chart and confirm it is available in the cluster. The Management Agent uses the Kubernetes resource metrics API for metrics collection.

Set `oci-onm-mgmt-agent.deployMetricServer` to `false` in the `oci-onm` installation. This is required when using this procedure so the chart does not deploy its own metrics-server component.

## Override the chart images

We recommend adding the following `--set` arguments to the `helm install` command received from the Cluster Connect flow. Replace the image URLs with your self-hosted image URLs.

```sh
--set oci-onm-logan.image.url=ocir.<region-identifier>.oci.oraclecloud.com/<tenancy-namespace>/oci_observability_management/oci-la-fluentd-collector:1.7.5 \
--set oci-onm-mgmt-agent.mgmtagent.image.url=ocir.<region-identifier>.oci.oraclecloud.com/<tenancy-namespace>/oci_observability_management/oci-management-agent:1.13.0 \
--set oci-onm-mgmt-agent.deployMetricServer=false
```

Alternatively, if you are using an external values file for the Cluster Connect installation inputs, add the following overrides to that file or to a separate override file. This example is not a complete installation values file; retain the other required Cluster Connect inputs.

```yaml
# self-hosted-images.yaml
oci-onm-logan:
  image:
    url: ocir.<region-identifier>.oci.oraclecloud.com/<tenancy-namespace>/oci_observability_management/oci-la-fluentd-collector:1.7.5

oci-onm-mgmt-agent:
  deployMetricServer: false
  mgmtagent:
    image:
      url: ocir.<region-identifier>.oci.oraclecloud.com/<tenancy-namespace>/oci_observability_management/oci-management-agent:1.13.0
```

When using a separate override file, install the chart with the Cluster Connect values file first and the self-hosted image overrides second. The later file takes precedence when a value is supplied in both files.

The `-f` flag supplies a values file to Helm.

```sh
helm repo add oci-onm https://oracle-quickstart.github.io/oci-kubernetes-monitoring
helm repo update
helm install oci-kubernetes-monitoring oci-onm/oci-onm \
  -f <cluster-connect-values.yaml> \
  -f self-hosted-images.yaml
```

### Private registry credentials

If the self-hosted repository is private, also configure image-pull credentials in the same values file.

For Fluentd:

1. Create an image-pull secret in the target namespace.
2. Set `oci-onm-logan.image.imagePullSecrets` to that secret's name.

For the Management Agent:

1. Base64-encode the contents of the Docker `config.json` file.
2. Set `oci-onm-mgmt-agent.mgmtagent.image.secret` to the encoded value.

The chart creates and uses the Management Agent image-pull secret.
