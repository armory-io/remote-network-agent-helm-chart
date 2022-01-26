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

# Development

## Testing / TDD'ing

Install the [unnitest helm plugin](https://github.com/quintush/helm-unittest) 

```bash
helm unittest --helm3 helm-chart
```
