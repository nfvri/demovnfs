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
| rbac.create | bool | `false` | Specifies whether a cluster role binding should be created |
| rbac.clusterRole | string | `"cluster-admin"` | The cluster role name |
| upf.s1u.iface | string | `"net0"` | s1u gateway interface name |
| upf.s1u.mac | string | `"9e:b2:d3:34:cc:28"` | s1u MAC addresses of gateway interface |
| upf.s1u.ip | string | `"198.18.0.1/30"` | s1u ip address |
| upf.s1u.nhip | string | `"198.18.0.2"` | s1u static ip address of its neighbor of gateway interface |
| upf.s1u.nhmac | string | `"22:53:7a:15:58:50"` | s1u static MAC addresses of the neighbor of gateway interface |
| upf.s1u.route | string | `"11.1.1.128/25"` | s1u IPv4 route table entry in cidr format |
| upf.sgi.iface | string | `"net1"` | sgi gateway interface name |
| upf.sgi.mac | string | `"c2:9c:55:d4:8a:1f"` | sgi MAC addresses of gateway interface |
| upf.sgi.ip | string | `"198.19.0.1/30"` | sgi ip address |
| upf.sgi.nhip | string | `"198.19.0.2"` | sgi static ip address of its neighbor of gateway interface |
| upf.sgi.nhmac | string | `"22:53:7a:15:58:50"` | sgi static MAC addresses of the neighbor of gateway interface |
| upf.sgi.route | string | `"0.0.0.0/0"` | sgi IPv4 route table entry in cidr format |
| bessd.command | list | `[]` | Override default container command (useful when using custom images or configmaps) |
| bessd.upfConfFile | string | `"/opt/bess/bessctl/conf/upf.json"` | Path of upf conf file. Populates the CONF_FILE env variable of bessd container. Default to /opt/bess/bessctl/conf/upf.json |
| bessd.securityContext | object | `{"capabilities":{"add":["NET_ADMIN","IPC_LOCK"]}}` | Security Context Configuration |
| bessd.resources.requests | object | `{"cpu":"6000m","hugepages-1Gi":"4Gi","intel.com/intel_sriov_dpdk_b2b_net1":"1","intel.com/intel_sriov_dpdk_b2b_net2":"1","memory":"2Gi"}` | The resources requests for the bessd container |
| bessd.resources.limits | object | `{"cpu":"6000m","hugepages-1Gi":"4Gi","intel.com/intel_sriov_dpdk_b2b_net1":"1","intel.com/intel_sriov_dpdk_b2b_net2":"1","memory":"2Gi"}` | The resources limits for the bessd container |
| bessd.readinessProbe | object | `{"initialDelaySeconds":30,"periodSeconds":20,"tcpSocket":{"port":10514}}` | OMEC UPF bessd container's readiness probe |
| bessd.livenessProbe | object | `{"initialDelaySeconds":30,"periodSeconds":20,"tcpSocket":{"port":10514}}` | OMEC UPF bessd container's liveness probe |
| bessd.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the bessd container |
| web.command | list | `[]` | Override default container command (useful when using custom images or configmaps) |
| web.readinessProbe | object | `{}` | OMEC UPF web container's readiness probe |
| web.livenessProbe | object | `{}` | OMEC UPF web container's liveness probe |
| web.resources.limits | object | `{"cpu":"1000m","memory":"512Mi"}` | The resources requests for the web container |
| web.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the web container |
| routectl.command | list | `[]` | Override default container command (useful when using custom images or configmaps) |
| routectl.securityContext | object | `{}` | Security Context Configuration |
| routectl.readinessProbe | object | `{}` | OMEC UPF routectl container's readiness probe |
| routectl.livenessProbe | object | `{}` | OMEC UPF routectl container's liveness probe |
| routectl.resources.limits | object | `{"cpu":"1000m","memory":"512Mi"}` | The resources requests for the routectl container   |
| routectl.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the routectl container |
| pfcpiface.command | list | `[]` | Override default container command (useful when using custom images or configmaps) |
| pfcpiface.readinessProbe | object | `{}` | OMEC UPF pfcpiface container's readiness probe |
| pfcpiface.livenessProbe | object | `{}` | OMEC UPF pfcpiface container's liveness probe |
| pfcpiface.resources.limits | object | `{"cpu":"1000m","memory":"512Mi"}` | The resources requests for the pfcpiface container   |
| pfcpiface.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the pfcpiface container |
| podAnnotations | object | `{"k8s.v1.cni.cncf.io/networks":"default/sriov-dpdk-b2b-net1,default/sriov-dpdk-b2b-net2"}` | podAnnotations Map of annotations to add to the pods |
| nodeSelector | object | `{"kubernetes.io/hostname":"clx2"}` | Node labels for omec-upf pods assignment |
| tolerations | array | `[]` | Tolerations for omec-upf pods assignment |
| affinity | object | `{}` | Affinity for omec-upf pods assignment |
| extraVolumes | array | `[]` | A list of volumes to be added to the pod |
