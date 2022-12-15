# STRESS-NG

![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

A Helm chart for deploying stress-ng on Kubernetes

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm install -n stress-ng stress-ng path/to/helm/chart
```

The command deploys stress-ng on the Kubernetes cluster in the default configuration.
The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete -n stress-ng my-release
```

The command removes all the Kubernetes components but PVC's associated with the chart and deletes the release.

## Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"quay.io/wcaban/stress-ng"` | image repository |
| image.pullPolicy | string | `"Always"` | image pull policy |
| image.tag | string | `"latest"` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| fullnameOverride | string | `""` |  |
| command | list | `[]` |  |
| config | object | `{}` |  |
| stress.cpuWorkers | int | `16` | Specifies the thread number |
| stress.maxLoad | int | `95` | Specifies the load in percentage |
| stress.timer | int | `60` | Specifies the loading time  |
| rbac.create | bool | `false` | Specifies whether a cluster role binding should be created |
| rbac.clusterRole | string | `"cluster-admin"` | The cluster role name |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.name | string | `""` |  |
| podAnnotations | object | `{}` | podAnnotations Map of annotations to add to the pods |
| podSecurityContext | object | `{}` |  |
| securityContext | object | `{"capabilities":{"add":["SYS_ADMIN"]}}` | Security Context Configuration |
| resources | object | `{}` |  |
| nodeSelector | object | `{}` | Node labels for stress-ng pods assignment |
| tolerations | array | `[]` | Tolerations for stress-ng pods assignment |
| affinity | object | `{}` | Affinity for stress-ng pods assignment |
