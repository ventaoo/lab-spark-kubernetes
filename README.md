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

#####  Minikube

> 📖 Minikube Doc - https://kubernetes.io/zh-cn/docs/tutorials/hello-minikube/


``` sh
# Step1. Install
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64 
sudo install minikube-darwin-arm64 /usr/local/bin/minikube
minikube version # show the version of minikube

# Step2. Start minikube (driver - docker)
minikube start --driver=docker
minikube status # show the status of server minikube

# Step3. Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -LSs https://dl.k8s.io/release/stable.txt )/bin/darwin/arm64/kubectl"
chmod +x kubectl
kubectl version --client # show the version of kubectl
```

``` sh
kubectl get nodes

NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   23m   v1.33.1
```

##### Env test






