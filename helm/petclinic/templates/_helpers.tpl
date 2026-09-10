{{- define "petclinic.fullname" -}}
{{ .Release.Name }}
{{- end -}}

{{- define "petclinic.labels" -}}
app.kubernetes.io/name: {{ include "petclinic.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
