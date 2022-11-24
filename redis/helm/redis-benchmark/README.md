# Redis Benchmark

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.2.8](https://img.shields.io/badge/AppVersion-3.2.8-informational?style=flat-square)

A Helm chart for deploying the redis-benchmark on Kubernetes.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm install -n redis-benchmark redis-benchmark path/to/helm/chart
```

The command deploys redis-benchmark on the Kubernetes cluster in the default configuration.
The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete -n redis-benchmark my-release
```

The command removes all the Kubernetes components but PVC's associated with the chart and deletes the release.

## Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of redis benchmark replicas to deploy |
| nameOverride | string | `""` | String to partially override chart name |
| fullnameOverride | string | `""` | String to fully override full chart name |
| imagePullSecrets | list | `[]` | Docker registry secret names as an array |
| podAnnotations | object | `{}` | Annotations for redis benchmark and replicas pods # ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| podSecurityContext | object | `{}` | Configure Pods Security Context |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| rbac.create | bool | `false` | Specifies whether a cluster role binding should be created |
| rbac.clusterRole | string | `"cluster-admin"` | The cluster role name |
| serviceMonitor.create | bool | `false` | Specify if service monitor will be created |
| serviceMonitor.monitoringNamespace | string | `"monitoring"` | Specify the namespace for the service monitor |
| serviceMonitor.monitoringLabels | object | `{"release":"k8s-prom"}` | Specify extra monitoring labels for the service monitor |
| serviceMonitor.scrapeInterval | string | `"5s"` | Specify the time scrape interval |
| serviceMonitor.scrapeTimeout | string | `"5s"` | Specify the scrape timeout |
| benchmark.image.repository | string | `"redis"` | benchmark image repository |
| benchmark.image.pullPolicy | string | `"IfNotPresent"` | benchmark image pull policy |
| benchmark.image.tag | string | `"3.2.8"` | Overrides the benchmark image tag whose default is the chart appVersion. |
| benchmark.command | array | `[]` | Overrides the default benchmark container command |
| benchmark.scripts | object | `{}` | Allows you to add any scripts files in {{ chartName }}-scripts configmap, such as redis_load.sh bash script |
| benchmark.securityContext | object | `{}` | Security Context Configuration |
| benchmark.resources | object | `{}` | Resources configuration of benchmark |
| benchmark.extraVolumeMounts | list | `[]` | Optionally specify extra list of additional volumeMounts for the redis master container(s) |
| redis.image.repository | string | `"redis"` | redis image repository |
| redis.image.pullPolicy | string | `"IfNotPresent"` | redis image pull policy |
| redis.image.tag | string | `"3.2.8"` | Overrides the redis image tag whose default is the chart appVersion. |
| redis.command | array | `[]` | Overrides the default redis container command |
| redis.config | object | `{}` | Allows you to add any config files in {{ chartName }}-config configmap, such as redis.conf file |
| redis.scripts | object | `{}` | Allows you to add any scripts files in {{ chartName }}-scripts configmap, such as redis_load.sh bash script |
| redis.securityContext | object | `{}` | Security Context Configuration |
| redis.service.type | string | `"ClusterIP"` | Specifies the type of service to deploy for redis |
| redis.service.port | int | `6379` | Specifies the port of service for redis |
| redis.resources | object | `{}` |  |
| redis.extraVolumeMounts | list | `[]` | Optionally specify extra list of additional volumeMounts for the redis master container(s) |
| exporter.image.repository | string | `"bitnami/redis-exporter"` | exporter image repository |
| exporter.image.pullPolicy | string | `"IfNotPresent"` |  |
| exporter.image.tag | string | `"latest"` | Overrides the image tag whose default is the chart appVersion. |
| exporter.securityContext | object | `{}` | Security Context Configuration |
| exporter.service.type | string | `"ClusterIP"` | Specifies the type of service to deploy for exporter |
| exporter.service.port | int | `9121` | Specifies the port of service for exporter |
| exporter.resources | object | `{}` |  |
| exporter.extraVolumeMounts | list | `[]` | Optionally specify extra list of additional volumeMounts for the exporter master container(s) |
| autoscaling.enabled | bool | `false` | Enable replica autoscaling settings |
| autoscaling.minReplicas | int | `1` | Minimum replicas for the pod autoscaling |
| autoscaling.maxReplicas | int | `100` | Maximum replicas for the pod autoscaling |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Percentage of CPU to consider when autoscaling |
| nodeSelector | object | `{}` | Node labels for redis benchmark pods assignment |
| tolerations | array | `[]` | Tolerations for redis benchmark pods assignment |
| affinity | object | `{}` | Affinity for redis benchmark pods assignment |
| extraVolumes | list | `[]` | Optionally specify extra list of additional volumes for the redis becnhmark master pod(s) |
