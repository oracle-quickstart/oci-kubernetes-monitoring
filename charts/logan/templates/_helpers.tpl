
# tpl render function
{{- define "common.tplvalues.render" -}}
  {{- if typeIs "string" .value }}
    {{- tpl .value .context }}
  {{- else }}
    {{- tpl (.value | toYaml) .context }}
  {{- end }}
{{- end -}}

# Prefix for all resources created using this chart.
{{- define "logan.resourceNamePrefix" -}}
  {{- if .Values.resourceNamePrefix -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.resourceNamePrefix "context" .) | trunc 63 | trimSuffix "-" }}
  {{- else -}}
    {{- .Chart.Name -}}
  {{- end -}}
{{- end -}}

# namespace
{{- define "logan.namespace" -}}
  {{- if .Values.namespace -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.namespace "context" .) }}
  {{- else -}}
    {{- "kube-system" -}}
  {{- end -}}
{{- end -}}

#serviceAccount
{{- define "logan.serviceAccount" -}}
  {{ include "common.tplvalues.render" ( dict "value" .Values.serviceAccount "context" .) }}
{{- end -}}

#kubernetesClusterId
{{- define "logan.kubernetesClusterId" -}}
  {{- if .Values.kubernetesClusterID -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.kubernetesClusterID "context" .) }}
  {{- else -}}
    {{- "UNDEFINED" -}}
  {{- end -}}
{{- end -}}

#kubernetesClusterName
{{- define "logan.kubernetesClusterName" -}}
  {{- if .Values.kubernetesClusterName -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.kubernetesClusterName "context" .) }}
  {{- else -}}
    {{- "UNDEFINED" -}}
  {{- end -}}
{{- end -}}
