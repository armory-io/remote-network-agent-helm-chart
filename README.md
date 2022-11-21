# remote-network-agent-helm-chart
Helm Chart for Armory's Remote Network Agent

# Basic Usage

See [Advanced Configuration](#advanced-configuration) to productionalize (use alternative secrets management, manage agent with Terraform, observability, etc.)

```shell
# Put your client credentials in a kubernetes secret (see advanced configuration for more secrets management options)
kubectl --namespace armory-rna create secret generic rna-client-credentials --type=string --from-literal=client-secret=xxx-yyy-ooo --from-literal=client-id=zzz-ooo-qqq
# Install or Upgrade armory rna chart
helm upgrade --install armory-rna remote-network-agent \
    --repo 'https://armory.jfrog.io/artifactory/charts' \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=fieldju-microk8s-cluster \
    --namespace armory-rna
```

# Advanced Configuration

Copy, read, and then edit the [values.yaml](values.yaml) file to configure advanced settings such as:

- Secrets Management outside of Kubernetes (AWS Secrets Manager, S3, Vault K8s Injector)
- Agent Proxy Settings
- Pod Labels
- Pod Annotations
- Pod Env Vars
- Pod Resource Requests / Limits
- Pod DNS Settings, 
- Pod Node selection, 
- Pod Affinity, 
- Pod Tolerations
- Log Configuration
  - output type (json vs human-readable text), level, color settings
- Disable kubernetes cluster mode
- etc 

Install using a custom values file.

```shell
# Install or Upgrade armory rna chart
helm upgrade --install \
    --repo 'https://armory.jfrog.io/artifactory/charts' \
    -f your-values-file.yaml \
    armory-rna remote-network-agent \
    --namespace armory-rna
```

Alternatively manage the agent with [Terraform with your Infrastructure as Code (IaC)](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)

```hcl
resource "helm_release" "armory-rna" {
  name            = "armory-rna"
  chart           = "remote-network-agent"
  repository      = "https://armory.jfrog.io/artifactory/charts"
  namespace       = "armory-rna"
  cleanup_on_fail = true
  values = [file("path/to/values.yaml")]
}
```

## Observability

### Metrics
The agent exposes an endpoint on `:8080/metrics` that is can serve prometheus or open-metrics format.

If you have a prometheus or open-metrics scrapper installed in your cluster such as one of the following:

You can enable the following annotations in you custom values file.

```yaml
 podAnnotations:
   prometheus.io/scrape: "true"
   prometheus.io/path: "/metrics"
   prometheus.io/port: "8080"
   prometheus.io/scheme: "http"
```

### Logging

By default the agent logs in a human-readable text, but you can enable structured json logging, which is often more appropriate for log aggregation (splunk, newrelic, etc)

```yaml
log:
  # Can be set to console or json
  type: console
```

# Development

## Testing / TDD'ing

This project uses [unnitest helm plugin](https://github.com/quintush/helm-unittest) for unit testing, see its docs. 

```bash
# requires docker and node
make check
```

You can also configure a values file in [scratch/values.yaml](scratch/values.yaml) and run [render.sh](render.sh) and it will produce  [scratch/manifests.yaml](scratch/manifests.yaml)
