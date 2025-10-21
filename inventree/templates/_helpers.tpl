{{/*
Expand the name of the chart.
*/}}
{{- define "inventree.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "inventree.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "inventree.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "inventree.labels" -}}
helm.sh/chart: {{ include "inventree.chart" . }}
{{ include "inventree.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels - server
*/}}
{{- define "inventree.selectorLabels" -}}
app.kubernetes.io/name: {{ include "inventree.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels - worker
*/}}
{{- define "inventree.worker.labels" -}}
helm.sh/chart: {{ include "inventree.chart" . }}
{{ include "inventree.worker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels - worker
*/}}
{{- define "inventree.worker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "inventree.name" . }}-worker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "inventree.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "inventree.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Render secrets
*/}}
{{- define "inventree.dbSecrets" -}}
{{- range .Values.global.dbSecrets }}
- name: {{ .name }}
{{- if .value }}
  value: {{ .value }}
{{- else if .valueFrom }}
  valueFrom:
    secretKeyRef:
      name: {{ .valueFrom.secretKeyRef.name }}
      key: {{ .valueFrom.secretKeyRef.key }}
{{- else }}
  {{- fail "Unhandled value, expecting either value for valueFrom"}}
{{- end }}
{{- end }}
{{- end }}
