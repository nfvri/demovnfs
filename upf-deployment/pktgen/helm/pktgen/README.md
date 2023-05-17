# pktgen

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for deploying the pktgen on Kubernetes.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm install pktgen path/to/helm/chart
```

The command deploys omec packet generators on the Kubernetes cluster in the default configuration.
The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components but PVC's associated with the chart and deletes the release.

## Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nodeSelector | object | `{}` | Node labels for node selection |
| securityContext.privileged | bool | `false` |  |
| securityContext.capabilities.add[0] | string | `"IPC_LOCK"` |  |
| image.repository | string | `"omecproject/upf-epc-bess"` | image repository |
| image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| image.tag | string | `"master-latest"` | image tag |
| rbac.create | bool | `false` | Specifies whether a cluster role binding should be created |
| rbac.clusterRole | string | `"cluster-admin"` | The cluster role name |
| serviceAccount.create | bool | `false` | Specifies whether a ServiceAccount should be created  |
| upf.s1u | string | `"3a:75:03:3c:7a:19"` | upf access interface MAC address |
| upf.sgi | string | `"4e:a6:53:e3:0f:65"` | upf core interface MAC address |
| overideConfigMap | bool | `false` | Select true when the user supplies custom traffic pattern, configMap and values override |
| access.command | list | `["bash","-xc","cp /conf/pktgen-access-weekly.bess /opt/bess/bessctl/conf/; bessd -grpc-url=0.0.0.0:10514; sleep 10; ./bessctl run pktgen-access-weekly"]` | Default container command to be executed (override when using custom configmaps and traffic patterns) |
| access.pattern | string | `"small"` | Pattern file will be used on access network. Select between small or large. |
| access.podAnnotations | object | `{}` |  |
| access.resources | object | `{"limits":{"cpu":"2000m","hugepages-1Gi":"4Gi","memory":"4Gi"},"requests":{"cpu":"2000m","hugepages-1Gi":"4Gi","memory":"4Gi"}}` | Container resources configuration |
| access.resources.requests | object | `{"cpu":"2000m","hugepages-1Gi":"4Gi","memory":"4Gi"}` | Resources requested by pktgen-access |
| access.resources.limits | object | `{"cpu":"2000m","hugepages-1Gi":"4Gi","memory":"4Gi"}` | Resources limits for pktgen-access |
| access.extraVolumeMounts | list | `[]` |  |
| access.extraVolumes | list | `[]` |  |
| core.podAnnotations | object | `{}` |  |
| core.command | list | `["bash","-xc","cp /conf/pktgen-core-weekly.bess /opt/bess/bessctl/conf/; bessd -grpc-url=0.0.0.0:10514; sleep 10; ./bessctl run pktgen-core-weekly"]` | Default container command to be executed (override when using custom configmaps and traffic patterns) |
| core.pattern | string | `"small"` | Pattern file will be used on core network. Select between small or large. |
| core.resources | object | `{"limits":{"cpu":"2000m","hugepages-1Gi":"4Gi","memory":"4Gi"},"requests":{"cpu":"2000m","hugepages-1Gi":"4Gi","memory":"4Gi"}}` | Container resources configuration |
| core.resources.requests | object | `{"cpu":"2000m","hugepages-1Gi":"4Gi","memory":"4Gi"}` | Resources requested by pktgen-access |
| core.resources.limits | object | `{"cpu":"2000m","hugepages-1Gi":"4Gi","memory":"4Gi"}` | Resources limits for pktgen-access |
| core.extraVolumeMounts | list | `[]` |  |
| core.extraVolumes | list | `[]` |  |
