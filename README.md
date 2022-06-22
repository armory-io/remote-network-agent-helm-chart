# remote-network-agent-helm-chart
Helm Chart for Armory's Remote Network Agent

# Basic Usage

Put your client credentials in a kubernetes secret (see [values.yaml](values.yaml) for more secrets management options)

```shell
kubectl --namespace armory-rna create secret generic rna-client-credentials --type=string --from-literal=client-secret=xxx-yyy-ooo --from-literal=client-id=zzz-ooo-qqq
```

And choose one of the following basic use cases.

## Basic installation with kubernetes-cluster-mode enabled, without customizing kubernetes account name
```shell
# Optionally Add Armory Chart repo, if you haven't
helm repo add armory https://armory.jfrog.io/artifactory/charts
# Update repo to fetch latest armory charts
helm repo update
# Install or Upgrade armory rna chart
helm upgrade --install armory-rna armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --namespace armory-rna
```

## installation with kubernetes-cluster-mode enabled + customizing the agent identifier
```shell
# Optionally Add Armory Chart repo, if you haven't
helm repo add armory https://armory.jfrog.io/artifactory/charts
# Update repo to fetch latest armory charts
helm repo update
# Install or Upgrade armory rna chart
helm upgrade --install armory-rna armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=fieldju-microk8s-cluster \
    --namespace armory-rna
```

## Installation with kubernetes-cluster-mode disabled
```shell
# Optionally Add Armory Chart repo, if you haven't
helm repo add armory https://armory.jfrog.io/artifactory/charts
# Update repo to fetch latest armory charts
helm repo update
# Install or Upgrade armory rna chart
helm upgrade --install armory-rna armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set kubernetes.enableClusterAccountMode=false \
    --namespace armory-rna
```

## Installation with kubernetes-cluster-mode disabled + customizing the agent identifier
```shell
# Optionally Add Armory Chart repo, if you haven't
helm repo add armory https://armory.jfrog.io/artifactory/charts
# Update repo to fetch latest armory charts
helm repo update
# Install or Upgrade armory rna chart
helm upgrade --install armory-rna armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set kubernetes.enableClusterAccountMode=false \
    --set agentIdentifier=fieldju-microk8s-cluster \
    --namespace armory-rna
```

## Installation with CPU and memory request limits 

### Note:

The defaults map to performant values that can be overriden. Increasing the requests and limits is useful when vertical scaling the RNA pods, but horizontal scaling is another approach to increase performance.

 `podMemoryRequest` and `podMemoryLimit` accepts `Mi` (for Mebibytes) and `M` (for Megabytes) units. `podCPURequest` and `podCPULimit` accept `m` for (millicpu) units.

### Defaults:
```
podMemoryRequest: "1500M"
podMemoryLimit: "2500M"
podCPURequest: "500m"
podCPULimit: "7500m"
```


You cannot set the requests and limits below the following values:

```
podMemoryRequest: "500Mi"
podMemoryLimit: "750Mi"
podCPURequest: "500m"
podCPULimit: "750m"
```

```shell
# Optionally Add Armory Chart repo, if you haven't
helm repo add armory https://armory.jfrog.io/artifactory/charts
# Update repo to fetch latest armory charts
helm repo update
# Install or Upgrade armory rna chart
helm upgrade --install armory-rna armory/remote-network-agent \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set memoryRequest=2000m \
    --set memoryLimit=2500Mi \
    --set cpuRequest=1500Mi \
    --set cpuLimit=2500m \
    --namespace armory-rna
```

# Advanced Usage

Copy, read, and then edit the [values.yaml](values.yaml) file.

```shell
# Optionally Add Armory Chart repo, if you haven't
helm repo add armory https://armory.jfrog.io/artifactory/charts
# Update repo to fetch latest armory charts
helm repo update
# Install or Upgrade armory rna chart
helm upgrade --install -f your-values-file.yaml armory-rna armory/remote-network-agent --namespace armory-rna
```

# Migrating from the Armory/Aurora meta helm chart

## Step 1: Update Client Credentials Scope in the Cloud Console

Go to the [Cloud Console](https://console.cloud.armory.io/configuration/credentials) and update the credentials you are using for your agent to have the newly required `connect:agentHub` scope. 

This scope is required to connect to the new agent-hub endpoint https://agent-hub.cloud.armory.io

## Step 2: Migrate your agent release from armory/aurora -> armory/remote-network-agent

If you installed the the armory/aurora helm chart like the following

```shell
helm install armory-rna armory/aurora \
      --set agent-k8s.accountName=<target-cluster-name> \
      --set agent-k8s.clientId=<clientID-for-rna> \
      --set agent-k8s.clientSecret=<clientSecret-for-rna>
      --namespace armory-rna
```

Then you can switch that release to this chart with the following commands and all your settings will be mapped.
The key here is that you are using the same release name `armory-rna` but changing the chart that the release is referencing.

```shell
helm repo update
helm upgrade armory-rna armory/remote-network-agent --namespace armory-rna
```

Please note that we now support and highly encourage the use of a secret's manager.
If you installed the original chart release via `--set agent-k8s.clientSecret=plain-text-value`

We recommend at least using a kubernetes secret and upgrading via the following.

```shell
kubectl create secret generic rna-client-credentials --type=string --from-literal=client-secret=xxx-yyy-ooo --from-literal=client-id=zzz-ooo-qqq
helm repo update
helm upgrade armory-rna armory/remote-network-agent \
  --set agent-k8s.clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
  --set agent-k8s.clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
  --namespace armory-rna
```

See [values.yaml](values.yaml) for more supported secret stores.

# Monitoring

There is a Prometheus (OpenMetrics) scrape endpoint on the pod at `/prometheus` on port `8080`

## Configuring Agent for Scraping

> This information assumes that your  Prometheus is configured with the default settings where it scrapes metrics from a pod based on its annotations.

You can configure the Agent to have its metrics scrapped by adding annotations to the `podAnnotations` value.

Update your chart to include the following annotations:

```yaml
...
podAnnotations:
  prometheus.io/scrape: true
  prometheus.io/path: /prometheus
  prometheus.io/port: 8080
...
```

## Customizing the Metrics

In advanced use cases, you might want to disallow metrics or add custom tags, labels, or dimensions to your metrics. 

For more information, see the official [actuator metrics documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics).

You can set properties described in the actuator docs with the `extraOpts` value option.

Update your chart values to use the `extraOpts` option. For example:

```yaml
extraOpts:
  - "-Dmanagement.metrics.enable.example.remote=false"
```

# Development

## Testing / TDD'ing

Install the [unnitest helm plugin](https://github.com/quintush/helm-unittest) 

```bash
helm unittest --helm3 helm-chart
```
