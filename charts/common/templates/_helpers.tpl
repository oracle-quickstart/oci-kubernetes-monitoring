
# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
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
{{- define "common.resourceNamePrefix" -}}
  {{- if .Values.resourceNamePrefix -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.resourceNamePrefix "context" .) | trunc 63 | trimSuffix "-" }}
  {{- else -}}
    {{- "oci-onm" -}}
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
    {{- "oci-onm" -}}
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
    {{ include "common.resourceNamePrefix" . }}
  {{- end -}}
{{- end -}}
