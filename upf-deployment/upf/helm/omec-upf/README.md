# OMEC-UPF

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.3.0](https://img.shields.io/badge/AppVersion-v0.3.0-informational?style=flat-square)

A Helm chart for deploying the OMEC UPF on Kubernetes.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm install -n omec-upf omec-upf path/to/helm/chart
```

The command deploys OMEC-UPF on the Kubernetes cluster in the default configuration.
The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete -n omec-upf my-release
```

The command removes all the Kubernetes components but PVC's associated with the chart and deletes the release.

## Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| shareProcessNamespace | bool | `true` | Configure process namespace sharing for pod |
| service.type | string | `"NodePort"` | Specifies the type of service to deploy |
| service.port | int | `80` | Specifies the port of service |
| service.nodePort | int | `30020` | Specifies the nodePort of service if the service type is NodePort |
| serviceAccount.create | bool | `false` | Specifies whether a ServiceAccount should be created  |
| serviceAccount.annotations | object | `{}` | Additional custom annotations for the ServiceAccount  |
| serviceAccount.name | string | `""` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template  |
| rbac.create | bool | `false` |  |
| rbac.clusterRole | string | `"cluster-admin"` |  |
| upf | object | `{"s1u":"9e:b2:d3:34:cc:28","sgi":"c2:9c:55:d4:8a:1f"}` | UPF network configuration |
| upf.s1u | string | `"9e:b2:d3:34:cc:28"` | s1u mac address. Default s1u mac 9e:b2:d3:34:cc:28 |
| upf.sgi | string | `"c2:9c:55:d4:8a:1f"` | sgi mac address. Default sgi mac c2:9c:55:d4:8a:1f |
| bessd.command | list | `[]` | Override default container command (useful when using custom images or configmaps) |
| bessd.upfConfFile | string | `"/opt/bess/bessctl/conf/upf.json"` | Path of upf conf file. Populates the CONF_FILE env variable of bessd container. Default to /opt/bess/bessctl/conf/upf.json |
| bessd.securityContext | object | `{"capabilities":{"add":["NET_ADMIN","IPC_LOCK"]}}` | Security Context Configuration |
| bessd.resources | object | `{"limits":{"cpu":"6000m","hugepages-1Gi":"4Gi","intel.com/intel_sriov_dpdk_b2b_net1":"1","intel.com/intel_sriov_dpdk_b2b_net2":"1","memory":"2Gi"},"requests":{"cpu":"6000m","hugepages-1Gi":"4Gi","intel.com/intel_sriov_dpdk_b2b_net1":"1","intel.com/intel_sriov_dpdk_b2b_net2":"1","memory":"2Gi"}}` | Resources configuration of bessd |
| bessd.readinessProbe | object | `{"initialDelaySeconds":30,"periodSeconds":20,"tcpSocket":{"port":10514}}` | OMEC UPF bessd container's readiness probe |
| bessd.livenessProbe | object | `{"initialDelaySeconds":30,"periodSeconds":20,"tcpSocket":{"port":10514}}` | OMEC UPF bessd container's liveness probe |
| bessd.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the bessd container |
| web.command | list | `[]` | Override default container command (useful when using custom images or configmaps) |
| web.readinessProbe | object | `{}` | OMEC UPF web container's readiness probe |
| web.livenessProbe | object | `{}` | OMEC UPF web container's liveness probe |
| web.resources | object | `{"limits":{"cpu":"1000m","memory":"512Mi"}}` | Resources configuration of web |
| web.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the web container |
| routectl.command | list | `[]` | Override default container command (useful when using custom images or configmaps) |
| routectl.securityContext | object | `{}` | Security Context Configuration |
| routectl.readinessProbe | object | `{}` | OMEC UPF routectl container's readiness probe |
| routectl.livenessProbe | object | `{}` | OMEC UPF routectl container's liveness probe |
| routectl.resources | object | `{"limits":{"cpu":"1000m","memory":"512Mi"}}` | Resources configuration of routectl |
| routectl.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the routectl container |
| pfcpiface.command | list | `[]` | Override default container command (useful when using custom images or configmaps) |
| pfcpiface.readinessProbe | object | `{}` | OMEC UPF pfcpiface container's readiness probe |
| pfcpiface.livenessProbe | object | `{}` | OMEC UPF pfcpiface container's liveness probe |
| pfcpiface.resources | object | `{"limits":{"cpu":"1000m","memory":"512Mi"}}` | Resources configuration of pfcpiface |
| pfcpiface.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the pfcpiface container |
| podAnnotations | object | `{"k8s.v1.cni.cncf.io/networks":"default/sriov-dpdk-b2b-net1,default/sriov-dpdk-b2b-net2"}` | podAnnotations Map of annotations to add to the pods |
| nodeSelector | object | `{"kubernetes.io/hostname":"clx2"}` | Node labels for omec-upf pods assignment |
| tolerations | array | `[]` | Tolerations for omec-upf pods assignment |
| affinity | object | `{}` | Affinity for omec-upf pods assignment |
| extraVolumes | array | `[]` | A list of volumes to be added to the pod |
