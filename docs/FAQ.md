## FAQ

### Can I use kubectl do deploy the solution?

Helm is recommended method of deployment. kubectl based deployment can be done by generating individual templates using helm using the following command.

### How to use your own ServiceAccount ?

**Note**: This is supported only through the helm chart based deployment.

By default, a cluster role, cluster role binding and serviceaccount will be created for the Fluentd pods to access (readonly) various objects within the cluster for supporting logs and objects collection. However, if you want to use your own serviceaccount, you can do the same by setting the "createServiceAccount" variable to false and providing your own serviceaccount in the "serviceAccount" variable. Ensure that the serviceaccount should be in the same namespace as the namespace used for the whole deployment. The namespace for the whole deployment can be set using the "namespace" variable, whose default value is "kube-system".

The serviceaccount must be binded to a cluster role defined in your cluster, which allows access to various objects metadata. The following sample is a recommended minimalistic role definition as of chart version 2.0.0.

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: oci-la-fluentd-generic-clusterrole
rules:
  - apiGroups:
      - ""
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - apps
      - batch
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
```

Once you have the cluster role defined, to bind the cluster role to your serviceaccount use the following cluster role binding definition.

```
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: oci-la-fluentd-generic-clusterrolebinding
roleRef:
  kind: ClusterRole
  name: oci-la-fluentd-generic-clusterrole
  apiGroup: rbac.authorization.k8s.io
subjects:
  - kind: ServiceAccount
    name: <serviceaccount>
    namespace: <namespace>
```

### How to set encoding for logs ?

**Note**: This is supported only through the helm chart based deployment.

By default Fluentd tail plugin that is being used to collect various logs has default encoding set to ASCII-8BIT. To overrided the default encoding, use one of the following approaches.

#### Global level

Set value for encoding under fluentd:tailPlugin section of values.yaml, which applies to all the logs being collected from the cluster.

```
fluentd:
  ...
  ...
  tailPlugin:
    ...
    ...
    encoding: <ENCODING-VALUE>
```

#### Specific log type level

The encoding can be set at invidivual log types like kubernetesSystem, linuxSystem, genericContainerLogs, which applies to all the logs under the specific log type.

```
fluentd:
  ...
  ...
  kubernetesSystem:
    ...
    ...
    encoding: <ENCODING-VALUE>
```

```
fluentd:
  ...
  ...
  genericContainerLogs:
    ...
    ...
    encoding: <ENCODING-VALUE>
```

#### Specific log level

The encoding can be set at individual log level too, which takes precedence over all others.

```
fluentd:
  ...
  ...
  kubernetesSystem:
    ...
    ...
    logs:
      kube-proxy:
        encoding: <ENCODING-VALUE>
```

```
fluentd:
  ...
  ...
  customLogs:
      custom-log1:
        ...
        ...
        encoding: <ENCODING-VALUE>
      ...
      ...
```
