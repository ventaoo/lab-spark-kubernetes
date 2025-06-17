# 使用包含 Java 的基础镜像
FROM openjdk:8-jdk-slim

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /data/spark-events

# 创建 python -> python3 的软链接
RUN ln -s /usr/bin/python3 /usr/bin/python

# 设置工作目录
WORKDIR /app

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 拷贝训练脚本
COPY . .

# 启动命令
CMD ["python", "train_model.py"]