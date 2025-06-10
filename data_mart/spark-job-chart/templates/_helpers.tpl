{{/* 通用标签 */}}
{{- define "datamart.labels" -}}
app: datamart
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
release: {{ .Release.Name }}
{{- end }}

{{- define "datamart.sparkSubmit" -}}
spark-submit \
--master k8s://https://kubernetes.default.svc \
--deploy-mode cluster \
--name {{ .Release.Name }}-datamart \
--class {{ .Values.spark.className }} \
--jars {{ .Values.spark.pgJarPath }} \
--conf spark.jars.ivy=/tmp/.ivy2 \
--conf spark.local.dir=/tmp/spark-local \
--conf spark.hadoop.security.authentication=simple \
--conf spark.hadoop.security.authorization=false \
--conf spark.executor.instances={{ .Values.spark.executorInstances }} \
--conf spark.driver.memory={{ .Values.spark.driverMemory }} \
--conf spark.executor.memory={{ .Values.spark.executorMemory }} \
--conf spark.kubernetes.container.image={{ .Values.spark.image }} \
--conf spark.kubernetes.namespace={{ .Release.Namespace }} \
--conf spark.kubernetes.authenticate.driver.serviceAccountName={{ .Values.spark.serviceAccount }} \
--conf spark.hadoop.fs.defaultFS=hdfs://{{ .Values.hdfs.namenode }}:{{ .Values.hdfs.port }} \
--conf spark.hadoop.dfs.client.use.datanode.hostname=true \
--conf spark.driver.extraJavaOptions="\
  -Djava.security.auth.login.config= \
  -Djava.security.krb5.conf= \
  -Divy.cache.dir=/tmp/.ivy2 \
  -DHADOOP_USER_NAME=spark \
  -Divy.home=/tmp/.ivy2" \
--conf spark.executor.extraJavaOptions="\
  -Djava.security.auth.login.config= \
  -Djava.security.krb5.conf= \
  -Divy.cache.dir=/tmp/.ivy2 \
  -DHADOOP_USER_NAME=spark \
  -Divy.home=/tmp/.ivy2" \
{{ .Values.spark.appJarPath }} \
{{ .Values.spark.inputPath }} \
{{ .Values.spark.sparkMaster }} \
{{ .Values.db.url }} \
{{ .Values.db.user }} \
{{ .Values.db.password }}
{{- end }}