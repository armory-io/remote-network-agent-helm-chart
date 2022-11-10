{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "armory-remote-network-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "armory-remote-network-agent.labels" -}}
helm.sh/chart: {{ include "armory-remote-network-agent.chart" . }}
{{ include "armory-remote-network-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "armory-remote-network-agent.selectorLabels" -}}
app.kubernetes.io/name: "remote-network-agent"
app.kubernetes.io/instance: {{ .Release.Name | lower }}
{{- end }}

{{/* Proxy Settings */}}
{{- define "armory-remote-network-agent.proxy-settings" -}}
- name: HTTPS_PROXY
  value: "{{ .Values.proxy.url }}"
{{- if not (empty .Values.proxy.nonProxyHosts) }}
- name: NO_PROXY
  value: "{{- .Values.proxy.nonProxyHosts }}"
{{- end }}
{{- end }}

{{/* function for sourcing the client id */}}
{{- define "armory-remote-network-agent.client-id" }}
    {{- if not (empty .Values.clientId) }}
      {{- .Values.clientId }}
    {{- else }}
      {{- fail "You must set clientId" }}
    {{- end }}
{{- end }}

{{/* function for sourcing the client secret */}}
{{- define "armory-remote-network-agent.client-secret" }}
    {{- if not (empty .Values.clientSecret) }}
      {{- .Values.clientSecret }}
    {{- else }}
      {{- fail "You must set clientSecret" }}
    {{- end }}
{{- end }}

{{/* function for generating pod annotations */}}
{{- define "armory-remote-network-agent.pod-annotations" }}
annotations:
    {{- range $key, $value := .Values.podAnnotations }}
  {{ $key }}: {{ $value | quote }}
    {{- end }}
{{- end }}

{{/* function for generating pod annotations */}}
{{- define "armory-remote-network-agent.pod-labels" }}
    {{- range $key, $value := .Values.podLabels }}
        {{ $key }}: {{ $value | quote }}
    {{- end }}
{{- end }}

{{/* function for generating pod environment variables */}}
{{- define "armory-remote-network-agent.pod-env-vars" }}
    {{- with .Values.podEnvironmentVariables }}
      {{- range . }}
- name: {{ index . "name" }}
  value: {{ index . "value" }}
      {{- end }}
    {{- end }}
{{- end }}

{{- /* Defines the pod priorityClassName */ -}}
{{- define "newrelic.common.priorityClassName" -}}
    {{- if .Values.priorityClassName -}}
        {{- .Values.priorityClassName -}}
    {{- end -}}
{{- end -}}

{{- /* Defines the Pod dnsConfig */ -}}
{{- define "armory-remote-network-agent.dnsConfig" -}}
    {{- if .Values.dnsConfig -}}
        {{- toYaml .Values.dnsConfig -}}
    {{- end -}}
{{- end -}}

{{- /* Defines the Pod nodeSelector */ -}}
{{- define "armory-remote-network-agent.nodeSelector" -}}
    {{- if .Values.nodeSelector -}}
        {{- toYaml .Values.nodeSelector -}}
    {{- end -}}
{{- end -}}

{{- /* Defines the Pod affinity */ -}}
{{- define "armory-remote-network-agent.affinity" -}}
    {{- if .Values.affinity -}}
        {{- toYaml .Values.affinity -}}
    {{- end -}}
{{- end -}}

{{- /* Defines the Pod tolerations */ -}}
{{- define "armory-remote-network-agent.tolerations" -}}
    {{- if .Values.tolerations -}}
        {{- toYaml .Values.tolerations -}}
    {{- end -}}
{{- end -}}
