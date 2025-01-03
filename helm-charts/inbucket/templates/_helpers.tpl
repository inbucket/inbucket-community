{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "inbucket.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "inbucket.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "inbucket.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name for the smtp tls secret.
*/}}
{{- define "inbucket.smtpTlsSecret" -}}
    {{- if .Values.inbucket.smtp.tls.secretName -}}
        {{- .Values.inbucket.smtp.tls.secretName -}}
    {{- else -}}
        {{- template "inbucket.fullname" . -}}-smtp-tls
    {{- end -}}
{{- end -}}

{{/*
Create the name for the tls secret.
*/}}
{{- define "inbucket.tlsSecret" -}}
    {{- if .Values.ingress.tls.existingSecret -}}
        {{- .Values.ingress.tls.existingSecret -}}
    {{- else -}}
        {{- template "inbucket.fullname" . -}}-tls
    {{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "inbucket.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "inbucket.ingress.isStable" -}}
  {{- eq (include "inbucket.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "inbucket.ingress.supportsPathType" -}}
  {{- or (eq (include "inbucket.ingress.isStable" .) "true") (and (eq (include "inbucket.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) -}}
{{- end -}}

{{/*
Return if persistence is enabled.
*/}}
{{- define "inbucket.persistenceEnabled" -}}
  {{- and ( and ( hasKey .Values "persistence" ) ( hasKey .Values.persistence "enabled" ) ) ( eq .Values.persistence.enabled true ) -}}
{{- end -}}

{{/*
Return if the smtp tls secret should be mounted.
*/}}
{{- define "inbucket.mountSmtpTlsSecret" -}}
  {{- and (hasKey .Values "inbucket") (hasKey .Values.inbucket "smtp") (hasKey .Values.inbucket.smtp "tls") (hasKey .Values.inbucket.smtp.tls "secretName") (ne .Values.inbucket.smtp.tls.secretName "") -}}
{{- end -}}
