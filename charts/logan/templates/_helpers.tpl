
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

#kubernetesClusterName
{{- define "logan.kubernetesClusterName" -}}
  {{- if .Values.kubernetesClusterName -}}
    {{ include "common.tplvalues.render" ( dict "value" .Values.kubernetesClusterName "context" .) }}
  {{- else -}}
    {{- "UNDEFINED" -}}
  {{- end -}}
{{- end -}}

{{- define "logan.tolerations" -}}
  {{- if kindIs "slice" .Values.tolerations -}}
    {{- include "common.tplvalues.render" ( dict "value" .Values.tolerations "context" .) -}}
  {{- else -}}
    {{- $tolerations := include "common.tplvalues.render" ( dict "value" .Values.tolerations "context" .) -}}
    {{- if $tolerations -}}
      {{- $noOuter := trimPrefix "[" (trimSuffix "]" $tolerations) -}}
      {{- $contents := regexSplit "map\\[" $noOuter -1 | rest -}}
      {{- range $content := $contents -}}
        {{- $trimmedContent := trimSuffix "]" (trimSuffix " " $content) -}}
        {{- $key := regexFind "key:([^ ]+)" $trimmedContent | trimPrefix "key:" -}}
        {{- $effect := regexFind "effect:([^ ]+)" $trimmedContent | trimPrefix "effect:" -}}
        {{- $operator := regexFind "operator:([^ ]+)" $trimmedContent | trimPrefix "operator:" -}}
        {{- $value := regexFind "value:([^ ]+)" $trimmedContent | trimPrefix "value:" -}}
        {{- $tolerationSeconds := regexFind "tolerationSeconds:([^ ]+)" $trimmedContent | trimPrefix "tolerationSeconds:" -}}
        {{- $firstPrinted := false -}}
        {{- if $key }}
          {{- if not $firstPrinted }}
- key: {{ $key | quote }}
            {{- $firstPrinted = true -}}
          {{- else }}
  key: {{ $key | quote }}
          {{- end }}
        {{- end }}
        {{- if $effect }}
          {{- if not $firstPrinted }}
- effect: {{ $effect | quote }}
            {{- $firstPrinted = true -}}
          {{- else }}
  effect: {{ $effect | quote }}
          {{- end }}
        {{- end }}
        {{- if $operator }}
          {{- if not $firstPrinted }}
- operator: {{ $operator | quote }}
            {{- $firstPrinted = true -}}
          {{- else }}
  operator: {{ $operator | quote }}
          {{- end }}
        {{- end }}
        {{- if $value }}
          {{- if not $firstPrinted }}
- value: {{ $value | quote }}
            {{- $firstPrinted = true -}}
          {{- else }}
  value: {{ $value | quote }}
          {{- end }}
        {{- end }}
        {{- if $tolerationSeconds }}
          {{- if not $firstPrinted }}
- tolerationSeconds: {{ $tolerationSeconds }}
            {{- $firstPrinted = true -}}
          {{- else }}
  tolerationSeconds: {{ $tolerationSeconds }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end -}}
{{- end -}}