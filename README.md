#### lab-spark-kubernetes

工作目标：通过将模型服务迁移到PySpark、数据集市服务迁移到Spark以及数据源服务，掌握使用Kubernetes进行容器编排的技能。
工作步骤：

1. 创建Spark计算基础设施，配置复制功能：
https://spark.apache.org/docs/latest/running-on-kubernetes.html  https://habr.com/ru/companies/neoflex/articles/511734/ 

2. 在Kubernetes集群(k8s)中启动模型服务（第五次实验版本）。检查其运行是否正常。
3. 启动数据源服务（第六次实验版本），并在Kubernetes集群中部署模型服务的更新。检查其运行是否正常。
4. 启动数据集市服务（第七次实验版本），并在Kubernetes集群中部署其他两个服务的更新。检查其运行是否正常。
5. 优化资源利用率。可以简化基础设施。
6. 允许打包为Helm Chart，使用OpenShift，以及在Kubernetes服务中存储敏感信息（secrets）。

___
```
[Source File .csv]
    |
    v
[Data Source Service (Lab6)] # 加载源文件上传到HDFS
    |
    v
[HDFS Storage]
    |
    v
[Data Mart Service (Lab7)] # 加载数据并预处理然后提交到数据库
    |
    v
[PostgreSQL]
    |
    v
[Model Training Service (Lab5)] # 从数据库加载数据训练模型
```
___

#####  Minikube

> 📖 Minikube Doc - https://kubernetes.io/zh-cn/docs/tutorials/hello-minikube/


``` sh
# Step1. Install
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64 
sudo install minikube-darwin-arm64 /usr/local/bin/minikube
minikube version # show the version of minikube

minikube delete
sudo rm -rf /var/lib/minikube
minikube addons enable registry     # 本地镜像仓库
minikube addons enable storage-provisioner  # 动态存储分配

# Step2. Start minikube (driver - docker)
minikube start --driver=docker
minikube status # show the status of server minikube

# Step3. Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -LSs https://dl.k8s.io/release/stable.txt )/bin/darwin/arm64/kubectl"
chmod +x kubectl
kubectl version --client # show the version of kubectl

# Step4. Install helm
brew install helm
helm version

# Step5. Install operator (🤖 目前未进行使用)
# https://github.com/apache/spark-kubernetes-operator
helm repo add spark-kubernetes-operator https://apache.github.io/spark-kubernetes-operator
helm repo update
helm install spark-kubernetes-operator spark-kubernetes-operator/spark-kubernetes-operator
helm uninstall spark-kubernetes-operator

kubectl get crd | grep spark
```

##### Set HDFS （Lab 提供数据源的部分）


``` bash
kubectl logs <datanode_name>
kubectl logs datanode-664bcc4c76-vlk4r # 查看日志
kubectl exec -it $(kubectl get pods | grep namenode | awk '{print $1}') -- bash # 进入namenode的shell
hdfs dfs -mkdir -p /data/{input,output,backup} # 创建数据湖的目录
hdfs dfs -ls /data/ # 查看验证是否存在创建的文件
kubectl cp ./data/en.openfoodfacts.org.products.csv.gz <namenode_name>:/tmp/ # 本地文件拷贝到容器内
hdfs dfs -put /tmp/en.openfoodfacts.org.products.csv.gz /data/input/

minikube service namenode --url
```

##### Set HDFS - Docker

``` bash
eval $(minikube docker-env) - eval $(minikube docker-env -u)
docker-compose up --build
```

