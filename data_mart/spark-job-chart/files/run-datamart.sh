#!/bin/bash

echo "===== 环境变量 ====="
printenv | sort

echo "===== 目录结构 ====="
echo "/tmp 目录:"
ls -la /tmp
echo "$IVY_HOME 目录:"
ls -la $IVY_HOME

echo "===== 开始执行Spark作业 ====="
{{ include "datamart.sparkSubmit" . }}

EXIT_CODE=$?
echo "===== Spark作业执行完成，退出码: $EXIT_CODE ====="

# 保留容器运行以便调试
if [ $EXIT_CODE -ne 0 ]; then
  echo "作业执行失败，将保留容器运行600秒供检查..."
  sleep 600
fi

exit $EXIT_CODE