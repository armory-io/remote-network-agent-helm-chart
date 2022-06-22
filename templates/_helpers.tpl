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

{{/* function for setting pod resource limits */}}
{{- define "armory-remote-network-agent.request-limits" }}
  {{- $podMemoryRequest := .Values.podMemoryRequest -}}
  {{- $podCPURequest := .Values.podCPURequest -}}
  {{- $podMemoryLimit := .Values.podMemoryLimit -}}
  {{- $podCPULimit := .Values.podCPULimit -}}
  {{/* set defaults */}}
  {{- if (empty $podMemoryRequest) }}
    {{- $podMemoryRequest = "1500Mi" -}}
  {{- end }}
  {{- if (empty $podCPURequest) }}
    {{- $podCPURequest = "500m" -}}
  {{- end }}
  {{- if (empty $podMemoryLimit) }}
    {{- $podMemoryLimit = "2500Mi" -}}
  {{- end }}
  {{- if (empty $podCPULimit) }}
    {{- $podCPULimit = "750m" -}}
  {{- end }}
  {{/* validate memory and cpu units */}}
  {{- $memoryReqWithUnit := regexFind "^([0-9.]+)Mi|M$" $podMemoryRequest -}}
  {{- if (empty $memoryReqWithUnit) }}
    {{- fail "podMemoryRequest value is not valid, please use Mi or M units" }}
  {{- end }}
  {{- $memoryReq := regexFind "^([0-9.]+)" $podMemoryRequest -}}
  {{- $cpuReqWithUnit := regexFind "^([0-9.]+)m$" $podCPURequest -}}
  {{- if (empty $cpuReqWithUnit) }}
    {{- fail "podCPURequest value is not valid, please use m units" }}
  {{- end }}
  {{- $cpuReq := regexFind "^([0-9.]+)" $podCPURequest -}}
  {{- $memoryLimitWithUnit := regexFind "^([0-9.]+)Mi|M$" $podMemoryLimit -}}
  {{- if (empty $memoryLimitWithUnit) }}
    {{- fail "podMemoryLimit value is not valid, please use Mi or M units" }}
  {{- end }}
  {{- $memoryLimit := regexFind "^([0-9.]+)" $podMemoryLimit -}}
  {{- $cpuLimitWithUnit := regexFind "^([0-9.]+)m$" $podCPULimit -}}
  {{- if (empty $cpuLimitWithUnit) }}
    {{- fail "podCPULimit value is not valid, please use m units" }}
  {{- end }}
  {{- $cpuLimit := regexFind "^([0-9.]+)" $podCPULimit -}}
  {{/* do memory unit conversions between Mib and M */}}
  {{- $memoryReqUnit := "M" -}}
  {{- if contains "Mi" $podMemoryRequest }}
    {{- $memoryReqUnit = "Mi" }}
  {{- end }}
  {{- $memoryLimitUnit := "M" -}}
  {{- if contains "Mi" $podMemoryLimit }}
    {{- $memoryLimitUnit = "Mi" }}
  {{- end }}
  {{ $memoryReqMi := float64 1500 -}}
  {{ $memoryReqM := float64 1573 -}}
  {{- if eq $memoryReqUnit "M"}}
    {{ $memoryReqMi = div (mul $memoryReq 95) 100 -}}
    {{ $memoryReqM = float64 $memoryReq -}}
  {{- else if eq $memoryReqUnit "Mi"}}
    {{ $memoryReqMi = float64 $memoryReq -}}
    {{ $memoryReqM = div (mul 105 (float64 $memoryReq)) 100 -}}
  {{- end }}
  {{ $memoryLimitMi := float64 2500 -}}
  {{ $memoryLimitM := float64 2621 -}}
  {{- if eq $memoryLimitUnit "M"}}
    {{ $memoryLimitMi = div (mul (float64 $memoryLimit) 95) 100 -}}
    {{ $memoryLimitM = float64 $memoryLimit -}}
  {{- else if eq $memoryLimitUnit "Mi"}}
    {{ $memoryLimitMi = float64 $memoryLimit -}}
    {{ $memoryLimitM = div (mul 105 (float64 $memoryLimit)) 100 -}}
  {{- end }}
  {{/* validate min values for memory and cpu */}}
  {{- if gt (float64 $memoryReqMi) (float64 $memoryLimitMi) }}
    {{- fail "podMemoryLimit must be greater than podMemoryRequest" }}
  {{- end }}
  {{- if gt $cpuReq $cpuLimit }}
    {{- fail "podCPULimit must be greater than podCPURequest" }}
  {{- end }}
  {{- if gt (float64 500) (float64 $memoryReqMi) }}
    {{- fail "podMemoryRequest must be greater than 500Mi" }}
  {{- end }}
  {{- if gt (float64 750) (float64 $memoryLimitMi) }}
    {{- fail "podMemoryLimit must be greater than 750Mi" }}
  {{- end }}
  {{- if gt 500 (int $cpuReq) }}
    {{- fail "podCPURequest must be greater than 500m" }}
  {{- end }}
  {{- if gt 750 (int $cpuLimit) }}
    {{- fail "podCPULimit must be greater than 750m" }}
  {{- end }}
  {{- if eq .Type "pod" -}}
  resources:
    requests:
      memory: {{ $memoryReqWithUnit }}
      cpu: {{ $cpuReqWithUnit }}
    limits:
      memory: {{ $memoryLimitWithUnit }}
      cpu: {{ $cpuLimitWithUnit }}
  {{- else if eq .Type "jvm"}}
    {{ $heapSize := div (mul 66 (float64 $memoryReqM)) 100 }}
    -Xms{{ $heapSize }}M
    -Xmx{{ $heapSize }}M
  {{- end }}
{{- end }}