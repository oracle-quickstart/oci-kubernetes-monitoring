
# Copyright (c) 2023, 2025, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

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
    {{- "oci-onm" -}}
  {{- end -}}
{{- end -}}

# namespace
{{- define "logan.namespace" -}}
  {{- if .Values.namespace -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.namespace "context" .) }}
  {{- else -}}
    {{- "oci-onm" -}}
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

#ociLAClusterEntityID
{{- define "logan.ociLAClusterEntityID" -}}
  {{ include "common.tplvalues.render" ( dict "value" .Values.ociLAClusterEntityID "context" .) }}
{{- end -}}

#kubernetesClusterName
{{- define "logan.kubernetesClusterName" -}}
  {{- if .Values.kubernetesClusterName -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.kubernetesClusterName "context" .) }}
  {{- else -}}
    {{- "UNDEFINED" -}}
  {{- end -}}
{{- end -}}

# Merge k8sDiscovery tolerations with global
{{- define "k8sdiscovery.mergeTolerations" -}}
{{- $result := concat (.Values.k8sDiscovery.tolerations | default list) (.Values.global.tolerations | default list) -}}
{{- toYaml $result -}}
{{- end -}}

# Merge tcpconnect tolerations with global
{{- define "tcpconnect.mergeTolerations" -}}
{{- $result := concat (.Values.tcpconnect.tolerations | default list) (.Values.global.tolerations | default list) -}}
{{- toYaml $result -}}
{{- end -}}

# Merge fluentd tolerations with global
{{- define "fluentd.mergeTolerations" -}}
{{- $result := concat (.Values.fluentd.tolerations | default list) (.Values.global.tolerations | default list) -}}
{{- toYaml $result -}}
{{- end -}}
