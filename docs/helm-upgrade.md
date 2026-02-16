### Upgrading to a major version

#### 3.6.0 to 4.0.0

For changes in this release, refer to [CHANGELOG.md](/CHANGELOG.md)

##### Upgrade instructions

1. Update IAM Policies:
    * This version requires additional policy statements for infrastructure discovery.
    * See the pre-requisites section in the [README](../README.md#pre-requisites) for details.

1. As mentioned in the change log, this version introduces a new DaemonSet that uses eBPF (Extended Berkeley Packet Filter) to capture TCP connection logs and builds application/network topology representing workload to workload relationships within the Kubernetes cluster.
    * To be able to run the required eBPF program, the pods needs to run in privileged mode but restricting to CAP_BPF capability only.
    * In your environment, if you have any restrictions with respect to running pods in privileged mode, you may need to adjust your cluster configuration accordingly.

2. Upgrade the Helm chart:

      ```sh
      # fetch latest (4.x) helm repo for oci
      helm repo update oci-onm

      # fetch the current release configuration
      helm get values <release-name> -n <namespace> > override_values.yaml
      
      # Upgrade the helm chart
      helm upgrade <release-name> oci/oci-onm -n <namespace> -f override_values.yaml
      ```


#### 2.x to 3.x

One of the major changes introduced in 3.0.0 is refactoring of helm chart where major features of the solution got split into separate sub-charts. 2.x has only support for logs and objects collection using Fluentd and OCI Log Analytics and this is now moved into a separate chart oci-onm-logan and included as a sub-chart to the main chart oci-onm. This is a breaking change w.r.t the values.yaml and any customizations that you might have done on top of it. There is no breaking change w.r.t functionality offered in 2.x. For full list of changes in 3.x, refer to [CHANGELOG.md](/CHANGELOG.md).

You may fall into one of the below categories and may need to take actions accordingly.
  
##### Have no customizations to the existing chart or values.yaml

We recommend you to uninstall the release created using 2.x chart and follow the installation instructions mentioned [here](../README.md#helm) for installing the release using 3.x chart.

###### Sample 2.x values.yaml (external or override yaml to update the mandatory variables)
  
    image:
       url: <Container Image URL>
       imagePullPolicy: Always
    ociLANamespace: <OCI LA Namespace>
    ociLALogGroupID: ocid1.loganalyticsloggroup.oc1.phx.amaaaaaa......
    kubernetesClusterID: ocid1.cluster.oc1.phx.aaaaaaaaa.......
    kubernetesClusterName: <Cluster Name>

###### Sample 3.x values.yaml
    
    global:
      # -- OCID for OKE cluster or a unique ID for other Kubernetes clusters.
      kubernetesClusterID: ocid1.cluster.oc1.phx.aaaaaaaaa.......
      # -- Provide a unique name for the cluster. This would help in uniquely identifying the logs and metrics data at OCI Log Analytics and OCI Monitoring respectively.
      kubernetesClusterName: <Cluster Name>

    oci-onm-logan:
      # Go to OCI Log Analytics Administration, click Service Details, and note the namespace value.
      ociLANamespace: <OCI LA Namespace>
      # OCI Log Analytics Log Group OCID
      ociLALogGroupID: ocid1.loganalyticsloggroup.oc1.phx.amaaaaaa......
      
##### Have customizations to the existing chart or values.yaml

If you have modified values.yaml provided in helm chart directly, we recommend you to identify all the changes and move them to override_values.yaml and follow the instructions provided in install or upgrade sections under [this](../README.md#helm). We recommend you to use override_values.yaml for updating values for any variables or to incorporate any customizations on top of existing values.yaml.
  
If you are already using a separate values.yaml for your customizations, you still need to compare 2.x vs 3.x variable hierarchy and make the necessary changes accordingly. 
  
<details>
  <summary>Examples</summary>
  
##### Example 1: Using docker runtime instead of default runtime (cri)
  
  **2.x**
  
    runtime: docker
    image:
       url: <Container Image URL>
       imagePullPolicy: Always
    ociLANamespace: <OCI LA Namespace>
    ociLALogGroupID: ocid1.loganalyticsloggroup.oc1.phx.amaaaaaa......
    kubernetesClusterID: ocid1.cluster.oc1.phx.aaaaaaaaa.......
    kubernetesClusterName: <Cluster Name>

  **3.x**
  
    global:
      # -- OCID for OKE cluster or a unique ID for other Kubernetes clusters.
      kubernetesClusterID: ocid1.cluster.oc1.phx.aaaaaaaaa.......
      # -- Provide a unique name for the cluster. This would help in uniquely identifying the logs and metrics data at OCI Log Analytics and OCI Monitoring respectively.
      kubernetesClusterName: <Cluster Name>

    oci-onm-logan:
      runtime: docker
      # Go to OCI Log Analytics Administration, click Service Details, and note the namespace value.
      ociLANamespace: <OCI LA Namespace>
      # OCI Log Analytics Log Group OCID
      ociLALogGroupID: ocid1.loganalyticsloggroup.oc1.phx.amaaaaaa......

 ##### Example 2: Customisation of a specific log
  
  **2.x**
  
    ...
    ...
    custom-log1:
      path: /var/log/containers/custom-1.log
      ociLALogSourceName: "Custom1 Logs"
      #multilineStartRegExp:
      isContainerLog: true 
    ...
    ...

  **3.x**
  
    ...
    ...
    oci-onm-logan:
      ...
      ...
      custom-log1:
        path: /var/log/containers/custom-1.log
        ociLALogSourceName: "Custom1 Logs"
        #multilineStartRegExp:
        isContainerLog: true 
      ...
      ...
    ...
    ...
  
  *The difference is all about moving the required configuration (variable definitions) under oci-onm-logan section appropriately.*
  
</details>
