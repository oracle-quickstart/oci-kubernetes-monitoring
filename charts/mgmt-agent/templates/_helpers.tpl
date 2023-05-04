
# tpl render function
{{- define "common.tplvalues.render" -}}
  {{- if typeIs "string" .value }}
    {{- tpl .value .context }}
  {{- else }}
    {{- tpl (.value | toYaml) .context }}
  {{- end }}
{{- end -}}

# Prefix for all resources created using this chart.
{{- define "mgmt-agent.resourceNamePrefix" -}}
  {{- if .Values.resourceNamePrefix -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.resourceNamePrefix "context" .) | trunc 63 | trimSuffix "-" }}
  {{- else -}}
    {{- "oci-onm" -}}
  {{- end -}}
{{- end -}}

# namespace
{{- define "mgmt-agent.namespace" -}}
  {{- if .Values.namespace -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.namespace "context" .) }}
  {{- else -}}
    {{- "oci-onm" -}}
  {{- end -}}
{{- end -}}

#serviceAccount
{{- define "mgmt-agent.serviceAccount" -}}
  {{ include "common.tplvalues.render" ( dict "value" .Values.serviceAccount "context" .) }}
{{- end -}}

#kubernetesClusterName
{{- define "mgmt-agent.kubernetesClusterName" -}}
  {{- if .Values.kubernetesCluster.name -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.kubernetesCluster.name "context" .) }}
  {{- else -}}
    {{- "UNDEFINED" -}}
  {{- end -}}
{{- end -}}
