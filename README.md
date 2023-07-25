# remote-network-agent-helm-chart
Helm Chart for Armory's Remote Network Agent

# Basic Usage

Basic settings are not meant for a production installation. See [Advanced Configuration](#advanced-configuration) for production options such as using alternative secrets management, managing the RNA with Terraform, and configuring observability.

```shell
# Put your Client Credentials in a Kubernetes secret (see advanced configuration for more secrets management options).
# Replace client-secret with your Client Secret and client-id with your Client Id.
# Replace <agent-identifier> with a unique name that identifies the Kubernetes cluster where you are installing the RNA.
kubectl --namespace armory-rna create secret generic rna-client-credentials --type=string --from-literal=client-secret=xxx-yyy-ooo --from-literal=client-id=zzz-ooo-qqq
# Install or Upgrade armory rna chart
helm upgrade --install armory-rna remote-network-agent \
    --repo 'https://armory.jfrog.io/artifactory/charts' \
    --set clientId='encrypted:k8s!n:rna-client-credentials!k:client-id' \
    --set clientSecret='encrypted:k8s!n:rna-client-credentials!k:client-secret' \
    --set agentIdentifier=<agent-identifier> \
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

Install using a custom values file:

```shell
# Install or Upgrade armory rna chart
helm upgrade --install \
    --repo 'https://armory.jfrog.io/artifactory/charts' \
    -f your-values-file.yaml \
    armory-rna remote-network-agent \
    --namespace armory-rna
```

Alternately, you can manage the RNA with [Terraform with your Infrastructure as Code (IaC)](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)

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

The RNA exposes an endpoint on `:8080/metrics` that can serve Prometheus or OpenMetrics format.

If you have a Prometheus or OpenMetrics scraper installed in your cluster, you can enable the following annotations in your custom values file:

```yaml
 podAnnotations:
   prometheus.io/scrape: "true"
   prometheus.io/path: "/metrics"
   prometheus.io/port: "8080"
   prometheus.io/scheme: "http"
```

### Logging

By default the RNA logs in human-readable text. However, you can enable structured JSON logging, which is often more appropriate for log aggregation by tools like Splunk and New Relic.

```yaml
log:
  # Can be set to console or json
  type: console
```

# Development

## Testing / TDDing

This project uses [helm-unittest](https://github.com/quintush/helm-unittest) for unit testing. See its repo docs for details. 

```bash
# requires docker and node
make check
```

You can also configure a values file in [scratch/values.yaml](scratch/values.yaml) and run [render.sh](render.sh) to produce  [scratch/manifests.yaml](scratch/manifests.yaml).
