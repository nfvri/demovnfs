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
| serviceMetrics.create | bool | `false` | Specifies whether the service metrics resource should be created |
| serviceMetrics.type | string | `"ClusterIP"` | Specifies the type of service to deploy |
| serviceMetrics.port | int | `8080` | Specifies the port of service |
| serviceMetrics.nodePort | int | `30022` | Specifies the nodePort of service if the service type is NodePort |
| serviceAccount.create | bool | `false` | Specifies whether a ServiceAccount should be created  |
| serviceAccount.annotations | object | `{}` | Additional custom annotations for the ServiceAccount  |
| serviceAccount.name | string | `""` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template  |
| rbac.create | bool | `false` | Specifies whether a cluster role binding should be created |
| rbac.clusterRole | string | `"cluster-admin"` | The cluster role name |
| serviceMonitor.create | bool | `false` | Specify if service monitor will be created |
| serviceMonitor.monitoringNamespace | string | `"monitoring"` | Specify the namespace for the service monitor |
| serviceMonitor.monitoringLabels | object | `{"release":"k8s-prom"}` | Specify extra monitoring labels for the service monitor |
| serviceMonitor.scrapeInterval | string | `"5s"` | Specify the time scrape interval |
| serviceMonitor.scrapeTimeout | string | `"5s"` | Specify the scrape timeout |
| upf.s1u.mac | string | `"9e:b2:d3:34:cc:28"` | s1u MAC addresses of gateway interface |
| upf.s1u.ip | string | `"198.18.0.1/30"` | s1u ip address |
| upf.s1u.nhip | string | `"198.18.0.2"` | s1u static ip address of its neighbor of gateway interface |
| upf.s1u.nhmac | string | `"22:53:7a:15:58:50"` | s1u static MAC addresses of the neighbor of gateway interface |
| upf.s1u.route | string | `"11.1.1.128/25"` | s1u IPv4 route table entry in cidr format |
| upf.s1u.pci | string | `"PCIDEVICE_INTEL_COM_INTEL_SRIOV_DPDK_B2B_NET1"` | s1u pci environment variable name |
| upf.sgi.mac | string | `"c2:9c:55:d4:8a:1f"` | sgi MAC addresses of gateway interface |
| upf.sgi.ip | string | `"198.19.0.1/30"` | sgi ip address |
| upf.sgi.nhip | string | `"198.19.0.2"` | sgi static ip address of its neighbor of gateway interface |
| upf.sgi.nhmac | string | `"22:53:7a:15:58:50"` | sgi static MAC addresses of the neighbor of gateway interface |
| upf.sgi.route | string | `"0.0.0.0/0"` | sgi IPv4 route table entry in cidr format |
| upf.sgi.pci | string | `"PCIDEVICE_INTEL_COM_INTEL_SRIOV_DPDK_B2B_NET1"` | s1u sgi environment variable name |
| bessd.image.repository | string | `"nfvri/upf-epc-8806-bess"` | bessd image repository |
| bessd.image.pullPolicy | string | `"IfNotPresent"` | bessd image pull policy |
| bessd.image.tag | string | `"0.3.0-dev"` | bessd image tag |
| bessd.command | array | `[]` | Override default container command (useful when using custom images or configmaps) |
| bessd.securityContext | object | `{"capabilities":{"add":["NET_ADMIN","IPC_LOCK"]}}` | Security Context Configuration |
| bessd.resources.requests | object | `{"cpu":"6000m","hugepages-1Gi":"4Gi","memory":"2Gi"}` | The resources requests for the bessd container |
| bessd.resources.limits | object | `{"cpu":"6000m","hugepages-1Gi":"4Gi","memory":"2Gi"}` | The resources limits for the bessd container |
| bessd.readinessProbe | object | `{"initialDelaySeconds":30,"periodSeconds":20,"tcpSocket":{"port":10514}}` | OMEC UPF bessd container's readiness probe |
| bessd.livenessProbe | object | `{"initialDelaySeconds":30,"periodSeconds":20,"tcpSocket":{"port":10514}}` | OMEC UPF bessd container's liveness probe |
| bessd.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the bessd container |
| web.image.repository | string | `"nfvri/upf-epc-8806-bess"` | web image repository |
| web.image.pullPolicy | string | `"IfNotPresent"` | web image pull policy |
| web.image.tag | string | `"0.3.0-dev"` | web image tag |
| web.command | array | `[]` | Override default container command (useful when using custom images or configmaps) |
| web.readinessProbe | object | `{}` | OMEC UPF web container's readiness probe |
| web.livenessProbe | object | `{}` | OMEC UPF web container's liveness probe |
| web.resources.limits | object | `{"cpu":"1000m","memory":"512Mi"}` | The resources requests for the web container |
| web.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the web container |
| routectl.image.repository | string | `"nfvri/upf-epc-8806-bess"` | routectl image repository |
| routectl.image.pullPolicy | string | `"IfNotPresent"` | routectl image pull policy |
| routectl.image.tag | string | `"0.3.0-dev"` | routectl image tag |
| routectl.command | array | `[]` | Override default container command (useful when using custom images or configmaps) |
| routectl.securityContext | object | `{}` | Security Context Configuration |
| routectl.readinessProbe | object | `{}` | OMEC UPF routectl container's readiness probe |
| routectl.livenessProbe | object | `{}` | OMEC UPF routectl container's liveness probe |
| routectl.resources.limits | object | `{"cpu":"1000m","memory":"512Mi"}` | The resources requests for the routectl container   |
| routectl.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the routectl container |
| pfcpiface.image.repository | string | `"nfvri/upf-epc-8806-pfcpiface"` | pfcpiface image repository |
| pfcpiface.image.pullPolicy | string | `"IfNotPresent"` | pfcpiface image pull policy |
| pfcpiface.image.tag | string | `"0.3.0-dev"` | pfcpiface image tag |
| pfcpiface.command | array | `[]` | Override default container command (useful when using custom images or configmaps) |
| pfcpiface.readinessProbe | object | `{}` | OMEC UPF pfcpiface container's readiness probe |
| pfcpiface.livenessProbe | object | `{}` | OMEC UPF pfcpiface container's liveness probe |
| pfcpiface.resources.limits | object | `{"cpu":"1000m","memory":"512Mi"}` | The resources requests for the pfcpiface container   |
| pfcpiface.extraVolumeMounts | array | `[]` | A list of volume mounts to be added to the pfcpiface container |
| config | object | `{}` | Allows you to add any config files in {{ chartName }}-config configmap, such as init_setup.sh bash script |
| podAnnotations | object | `{}` | podAnnotations Map of annotations to add to the pods |
| nodeSelector | object | `{}` | Node labels for omec-upf pods assignment |
| tolerations | array | `[]` | Tolerations for omec-upf pods assignment |
| affinity | object | `{}` | Affinity for omec-upf pods assignment |
| extraVolumes | array | `[]` | A list of volumes to be added to the pod |
