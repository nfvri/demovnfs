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
| service.type | string | `"NodePort"` | Specifies the type of service to deploy |
| service.port | int | `80` | Specifies the port of service |
| service.nodePort | int | `30020` | Specifies the nodePort of service if the service type is NodePort |
| bessd.securityContext | object | `{"capabilities":{"add":["NET_ADMIN","IPC_LOCK"]}}` | Security Context Configuration |
| bessd.resources | object | `{"limits":{"cpu":"6000m","hugepages-1Gi":"4Gi","intel.com/intel_sriov_dpdk_b2b_net1":"1","intel.com/intel_sriov_dpdk_b2b_net2":"1","memory":"2Gi"},"requests":{"cpu":"6000m","hugepages-1Gi":"4Gi","intel.com/intel_sriov_dpdk_b2b_net1":"1","intel.com/intel_sriov_dpdk_b2b_net2":"1","memory":"2Gi"}}` | Resources configuration of bessd |
| web.resources | object | `{"limits":{"cpu":"1000m","memory":"512Mi"}}` | Resources configuration of web |
| routectl.resources | object | `{"limits":{"cpu":"1000m","memory":"512Mi"}}` | Resources configuration of routectl |
| pfcpiface.resources | object | `{"limits":{"cpu":"1000m","memory":"512Mi"}}` | Resources configuration of pfcpiface |
| podAnnotations | object | `{"k8s.v1.cni.cncf.io/networks":"default/sriov-dpdk-b2b-net1,default/sriov-dpdk-b2b-net2"}` | podAnnotations Map of annotations to add to the pods |
| nodeSelector | object | `{"kubernetes.io/hostname":"clx2"}` | Node labels for omec-upf pods assignment |
| tolerations | array | `[]` | Tolerations for nfvri-apiserver pods assignment |
| affinity | object | `{}` | Affinity for nfvri-apiserver pods assignment |
