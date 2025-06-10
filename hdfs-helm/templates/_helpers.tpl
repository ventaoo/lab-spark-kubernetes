{{/* 通用标签 */}}
{{- define "hdfs.labels" -}}
app: hdfs
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
release: {{ .Release.Name }}
{{- end }}

{{/* Namenode 选择器标签 */}}
{{- define "namenode.selectorLabels" -}}
app: namenode
{{- end }}

{{/* Datanode 选择器标签 */}}
{{- define "datanode.selectorLabels" -}}
app: datanode
{{- end }}