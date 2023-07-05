{{- /*
Ignore the user's set storageClass value if they have requested local hostPath
volumes.
*/ -}}
{{- define "global.storageClass" -}}
{{- if .Values.dbLocalVolumes.create -}}
""
{{- else -}}
{{ .Values.mysql.global.storageClass }}
{{- end }}
{{- end -}}

{{- /*
Generate database hostname consistent with the naming rules used by the
bitnami/mysql dependency chart to correctly connect the server to the db.
*/ -}}
{{- define "db.hostname" -}}
{{- default .Release.Name .Values.nameOverride | trunc 31 | trimSuffix "-" }}
{{- if .Values.mysql.nameOverride -}}
{{- (printf "%s%s" "-" .Values.mysql.nameOverride) }}
{{- else -}}
""
{{- end -}}
-primary
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "go-serve.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "go-serve.fullname" -}}
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
{{- define "go-serve.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "go-serve.labels" -}}
helm.sh/chart: {{ include "go-serve.chart" . }}
{{ include "go-serve.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "go-serve.selectorLabels" -}}
app.kubernetes.io/name: {{ include "go-serve.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "go-serve.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "go-serve.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
