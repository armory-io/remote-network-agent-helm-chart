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

{{/*
HTTP|HTTPS Proxy Settings
*/}}
{{- define "armory-remote-network-agent.proxy-settings" -}}
- name: PROXY_OPTS
  value: >-
    -D{{.Values.proxy.scheme}}.proxyHost={{ .Values.proxy.host }}
    -D{{.Values.proxy.scheme}}.proxyPort={{ .Values.proxy.port }}
    {{- if not (empty .Values.proxy.nonProxyHosts) }}
    -Dhttp.nonProxyHosts={{- .Values.proxy.nonProxyHosts }}
    {{- end }}
{{- end }}

{{/* function for sourcing the client id */}}
{{- define "armory-remote-network-agent.client-id" }}
    {{- if not (empty .Values.clientId) }}
      {{- .Values.clientId }}
    {{- else if not (empty (index .Values "agent-k8s")) }}
      {{- if empty (index .Values "agent-k8s" "clientId")}}
        {{- fail "You must set clientId" }}
       {{- end }}
      {{- (index .Values "agent-k8s" "clientId") }}
    {{- else }}
      {{- fail "You must set clientId" }}
    {{- end }}
{{- end }}

{{/* function for sourcing the client secret */}}
{{- define "armory-remote-network-agent.client-secret" }}
    {{- if not (empty .Values.clientSecret) }}
      {{- .Values.clientSecret }}
    {{- else if not (empty (index .Values "agent-k8s")) }}
      {{- if empty (index .Values "agent-k8s" "clientSecret")}}
        {{- fail "You must set clientSecret" }}
       {{- end }}
      {{- (index .Values "agent-k8s" "clientSecret") }}
    {{- else }}
      {{- fail "You must set clientSecret" }}
    {{- end }}
{{- end }}

{{/* function for sourcing the agent identifier */}}
{{- define "armory-remote-network-agent.agent-identifier" }}
    {{- if not (empty .Values.agentIdentifier) }}
      -Dagent-identifier={{- .Values.agentIdentifier }}
    {{- else if not (empty (index .Values "agent-k8s")) }}
      {{- if not (empty (index .Values "agent-k8s" "accountName")) }}
        -Dagent-identifier={{- (index .Values "agent-k8s" "accountName") }}
      {{- end }}
    {{- end }}
{{- end }}

{{/* function for generating pod annotations */}}
{{- define "armory-remote-network-agent.pod-annotations" }}
  {{- if .Values.podAnnotations }}
annotations:
    {{- range $key, $value := .Values.podAnnotations }}
  {{ $key }}: {{ $value | quote }}
    {{- end }}
 {{- else if not (empty (index .Values "agent-k8s")) }}
    {{- if (index .Values "agent-k8s" "podAnnotations") }}
annotations:
      {{- range $key, $value := (index .Values "agent-k8s" "podAnnotations") }}
  {{ $key }}: {{ $value | quote }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{/* function for generating pod annotations */}}
{{- define "armory-remote-network-agent.pod-labels" }}
  {{- if .Values.podLabels }}
    {{- range $key, $value := .Values.podLabels }}
        {{ $key }}: {{ $value | quote }}
    {{- end }}
 {{- else if not (empty (index .Values "agent-k8s")) }}
    {{- if (index .Values "agent-k8s" "podLabels") }}
      {{- range $key, $value := (index .Values "agent-k8s" "podLabels") }}
        {{ $key }}: {{ $value | quote }}
      {{- end }}
    {{- end }}
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
    {{- if not (empty (index .Values "agent-k8s")) }}
        {{- if (index .Values "agent-k8s" "env") }}
            {{- with (index .Values "agent-k8s" "env") }}
                {{- range . }}
- name: {{ index . "name" }}
  value: {{ index . "value" }}
                {{- end }}
            {{- end }}
        {{- end }}
    {{- end }}
{{- end }}