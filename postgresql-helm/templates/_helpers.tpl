{{/* 通用标签 */}}
{{- define "postgresql.labels" -}}
app: postgresql
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
release: {{ .Release.Name }}
{{- end }}

{{/* 选择器标签 */}}
{{- define "postgresql.selectorLabels" -}}
app: postgresql
release: {{ .Release.Name }}
{{- end }}