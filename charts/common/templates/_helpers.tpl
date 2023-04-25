
# tpl render function
{{- define "common.tplvalues.render" -}}
  {{- if typeIs "string" .value }}
    {{- tpl .value .context }}
  {{- else }}
    {{- tpl (.value | toYaml) .context }}
  {{- end }}
{{- end -}}

# Prefix for all resources created using this chart.
{{- define "common.resourceNamePrefix" -}}
  {{- if .Values.resourceNamePrefix -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.resourceNamePrefix "context" .) | trunc 63 | trimSuffix "-" }}
  {{- else -}}
    {{- "oci-kubernetes-monitoring" -}}
  {{- end -}}
{{- end -}}

#createNamespace
{{- define "common.createNamespace" -}}
  {{ include "common.tplvalues.render" ( dict "value" .Values.createNamespace "context" .) }}
{{- end -}}

# namespace
{{- define "common.namespace" -}}
  {{- if .Values.namespace -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.namespace "context" .) }}
  {{- else -}}
    {{- "kube-system" -}}
  {{- end -}}
{{- end -}}

#createServiceAccount
{{- define "common.createServiceAccount" -}}
  {{ include "common.tplvalues.render" ( dict "value" .Values.createServiceAccount "context" .) }}
{{- end -}}

#serviceAccount
{{- define "common.serviceAccount" -}}
  {{- if .Values.serviceAccount -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.serviceAccount "context" .) }}
  {{- else -}}
    {{ include "common.resourceNamePrefix" . }}-serviceaccount
  {{- end -}}
{{- end -}}
