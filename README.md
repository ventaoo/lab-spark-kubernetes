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
```

##### HDFS helm

- Step1. Install
``` bash
helm install hdfs-cluster ./hdfs-helm
```

- Step2. Upload the file (`source_data`) to HDFS
``` bash
kubectl exec -it $(kubectl get pods | grep namenode | awk '{print $1}') -- bash
hdfs dfs -mkdir -p /data/{input,output,backup}

kubectl cp ./files/en.openfoodfacts.org.products.csv.gz $(kubectl get pods | grep namenode | awk '{print $1}'):/tmp/ 

kubectl exec -it $(kubectl get pods | grep namenode | awk '{print $1}') -- bash
hdfs dfs -put /tmp/en.openfoodfacts.org.products.csv.gz /data/input/
```

- Step3. Create Jar & Upload
```bash
sbt clean assembly

kubectl exec -it $(kubectl get pods | grep namenode | awk '{print $1}') -- bash 
hdfs dfs -mkdir -p /spark-uploads
hdfs dfs -chmod 777 /spark-uploads

kubectl cp ./target/scala-2.12/datamart-assembly-0.1.jar $(kubectl get pods | grep namenode | awk '{print $1}'):/tmp/
kubectl cp ./jar/target/scala-2.12/postgresql-42.6.0.jar $(kubectl get pods | grep namenode | awk '{print $1}'):/tmp/ 
kubectl exec -it $(kubectl get pods | grep namenode | awk '{print $1}') -- bash 
hdfs dfs -put /tmp/*.jar /spark-uploads
```

- Step4. Check file in the web
``` bash
minikube service hdfs-cluster-namenode --url
```

##### Datamart helm (HDFS -> Data_mart -> Database)

![Spark in k8s](https://spark.apache.org/docs/latest/img/k8s-cluster-mode.png)

- Step1. Init database
``` bash
helm install postgresql ./postgresql-helm --set postgresql.password=postgres

kubectl exec -it $(kubectl get pods | grep postgres | awk '{print $1}') -- psql -U postgres -d datamartdb -c 'SELECT * FROM processed_data LIMIT 5;'
```

- Step2. Image to Minikube
``` bash
eval $(minikube docker-env) - eval $(minikube docker-env -u)
docker build -t datamart:latest .
```

- Step3. Install
``` bash
helm install datamart ./spark-job-chart \                                               
  --set hdfs.namenode="hdfs-cluster-namenode" \
  --set db.host="postgresql-postgres" \
  --set db.password=postgres
```

##### Database -> model training

``` bash
docker build -t model-training:latest .

# 安装Chart（假设已存在datamart-db-secret）
helm install model-training ./model-training-chart \ 
  --set db.password=postgres
```


``` bash
kubectl get pods
model-training-job-kvd4c                    0/1     Completed   0               4h22m


kubectl describe pv pvc-a6186cf4-b0b1-4605-9f99-e6367092bf75

Name:            pvc-a6186cf4-b0b1-4605-9f99-e6367092bf75
Labels:          <none>
Annotations:     hostPathProvisionerIdentity: 0b082bb0-2b8b-45ba-a1ef-dd1715e75693
                 pv.kubernetes.io/provisioned-by: k8s.io/minikube-hostpath
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    standard
Status:          Bound
Claim:           default/training-data-pvc
Reclaim Policy:  Delete
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        1Gi
Node Affinity:   <none>
Message:         
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /tmp/hostpath-provisioner/default/training-data-pvc
    HostPathType:  
Events:            <none>

minikube ssh

docker@minikube:~$ cd /tmp/hostpath-provisioner/default/training-data-pvc

ls
app.log  model  spark-events
```