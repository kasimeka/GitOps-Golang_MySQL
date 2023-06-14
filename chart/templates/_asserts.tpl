{{- define "asserts.dbPort" -}}
{{- if (ne .Values.dbPort .Values.mysql.primary.service.ports.mysql) -}}
{{- fail (printf "%s%s%s%s%s%s%s%s%s%s%s"
"values.yml consistency error: .Values.dbPort and"
" .Values.mysql.primary.service.ports.mysql must have the same value\n"
"Use yaml anchors to avoid duplication.\n"
"Example:\n"
"# values.yml\n"
"dbPort: &dbPort 3306\n"
"mysql:\n"
"  primary:\n"
"    service:\n"
"      ports:\n"
"        mysql: *dbPort\n")
 -}}
{{- end -}}
{{- end -}}

{{- define "asserts.dbUser" -}}
{{- if (ne .Values.dbUser .Values.mysql.auth.username) -}}
{{- fail (printf "%s%s%s%s%s%s%s%s%s%s"
"values.yml consistency error: .Values.dbUser and"
" .Values.mysql.auth.username must have the same value\n"
"Use yaml anchors to avoid duplication.\n"
"Example:\n"
"# values.yml\n"
"dbUser: &dbUser go-server\n"
"mysql:\n"
"  primary:\n"
"    auth:\n"
"      username: *dbUser\n")
 -}}
{{- end -}}
{{- end -}}

{{- define "asserts.dbPrimaryPVC" -}}
{{- if (ne .Values.dbPrimaryPVCName .Values.mysql.primary.persistence.existingClaim) -}}
{{- fail (printf "%s%s%s%s%s%s%s%s%s"
"values.yml consistency error: .Values.dbPrimaryPVCName and"
" .Values.mysql.primary.persistence.existingClaim must have the same value\n"
"Use yaml anchors to avoid duplication.\n"
"Example:\n"
"# values.yml\n"
"dbPrimaryPVCName: &dbPrimaryPVC db-primary-pvc\n"
"mysql:\n"
"  primary:\n"
"    persistence:\n"
"      existingClaim: *dbPrimaryPVC\n")
 -}}
{{- end -}}
{{- end -}}

{{- define "asserts.dbSecondaryPVCName" -}}
{{- if (ne .Values.dbSecondaryPVCName .Values.mysql.secondary.persistence.existingClaim) -}}
{{- fail (printf "%s%s%s%s%s%s%s%s%s%s"
"values.yml consistency error: .Values.dbSecondaryPVCName and"
" .Values.mysql.secondary.persistence.existingClaim must have the same value\n"
"Use yaml anchors to avoid duplication.\n"
"Example:\n"
"# values.yml\n"
"dbSecondaryPVCName: &dbSecondaryPVC db-secondary-pvc\n"
"mysql:\n"
"  secondary:\n"
"    persistence:\n"
"      existingClaim: *dbSecondaryPVC\n")
 -}}
{{- end -}}
{{- end -}}

{{- define "asserts.global.storageClass" -}}
{{- if (ne .Values.global.storageClass .Values.mysql.global.storageClass) -}}
{{- fail (printf "%s%s%s%s%s%s%s%s%s"
"values.yml consistency error: .Values.global.storageClass"
" and .Values.mysql.global.storageClass must have the same value\n"
"Use yaml anchors to avoid duplication.\n"
"Example:\n"
"# values.yml\n"
"global:\n"
"  storageClass: &storageClass standard\n"
"mysql:\n"
"    global:\n"
"        storageClass: *storageClass\n")
 -}}
{{- end -}}
{{- end -}}

{{- define "asserts.dbSecretName" -}}
{{- if (ne .Values.dbSecretName .Values.mysql.auth.existingSecret) -}}
{{- fail (printf "%s%s%s%s%s%s%s%s%s"
"values.yml consistency error: .Values.dbSecretName and"
" .Values.mysql.auth.existingSecret must have the same value\n"
"Use yaml anchors to avoid duplication.\n"
"Example:\n"
"# values.yml\n"
"dbSecretName: &dbSecretName db-secret\n"
"mysql:\n"
"  primary:\n"
"    auth:\n"
"      existingSecret: *dbSecretName\n")
 -}}
{{- end -}}
{{- end -}}
