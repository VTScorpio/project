# 📦 Platforma de Backup si Monitorizare - Proiect DevOps

## 🔍 Descriere generală

Acest proiect DevOps este o platformă modulară ce asigură:

* **Backup automat** al stării sistemului (load, memorie, disk etc.).
* **Monitorizare periodică** cu loguri salvate persistent.
* **CI/CD complet** folosind **Jenkins**.
* **Containere Docker** pentru izolare.
* **Deploy local in Minikube** (opțional).
* **Provisionare infrastructură AWS local cu LocalStack** prin **Terraform**.

## 📁 Structura proiectului

```
project/

├── ansible
│   ├── install-docker.yml
│   ├── inventory.ini
│   └── run-platform.yml
├── backup
│   ├── backup.py
│   ├── Dockerfile
│   └── test_backup.py
├── backup-data  [error opening dir]
├── data  [error opening dir]
├── docker-compose.yml
├── Jenkins
│   ├── backup
│   │   └── Jenkinsfile
│   └── mon
│       └── Jenkinsfile
├── k8s
│   ├── backup-deployment.yaml
│   ├── backup-service.yaml
│   ├── k8s.sh
│   ├── monitor-deployment.yaml
│   └── monitor-service.yaml
├── mon
│   ├── Dockerfile
│   └── mon.sh
├── README.md
├── README.md.old
├── setup.sh
└── terraform
    ├── backend.tf
    ├── main.tf
    ├── main.tf.old
    ├── outputs.tf
    ├── terraform.tfvars
    ├── user_data.sh
    └── variables.tf

```


## ⚙️ Instalare și rulare locală

### 🔧 Cerințe minime:

* Python 3.8+
* Docker
* Jenkins
* Minikube (opțional)
* Terraform
* LocalStack (versiune full)

### 1. 🔁 Clonează proiectul

```bash
git clone https://github.com/VTScorpio/project.git
cd project
```

### 2. 🔧 Rulare script Python de backup

```bash
cd backup
python3 backup.py
cat data/system-state.log
```

### 3. 🐍 Testare unitară cu Pytest

```bash
pytest test_backup.py -s
```

### 4. 🔧 Rulare script monitor Bash

```bash
cd monitor
bash monitor.sh
cat logs/monitor.log
```

---

## 🐳 Containere Docker

### 1. 📦 Build imagine Backup

```bash
cd backup
docker build -t backup-image .
```

### 2. 📦 Build imagine Monitor

```bash
cd monitor
docker build -t monitor-image .
```

---

## 🔁 CI/CD cu Jenkins

### 📌 Pipeline Python (`Jenkinsfile-backup`):

* Lint: `python -m py_compile`
* Teste unitare: `pytest`
* Docker build
* Push în DockerHub

### 📌 Pipeline Bash (`Jenkinsfile-monitor`):

* Docker build
* Push în DockerHub

### 🔐 Utilizator și View dedicat:

* User: `ci-cd-user`
* View: `DevOps Project View`

---

## ☸️ Deploy în Minikube (opțional)

```bash
kubectl config use-context minikube
kubectl apply -f k8s/
kubectl get pods
```

---

## ☁️ Provisionare AWS Local cu Terraform

### 1. Pornește LocalStack

```bash
localstack start
```

### 2. Inițializează și aplică Terraform

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### 3. Verificare S3 + EC2 (simulat)

```bash
awslocal s3 ls
awslocal ec2 describe-instances --output table
```

---

## ✅ Verificări finale

* Backup salvat în `backup/data/`
* Loguri monitor în `monitor/logs/`
* Pipeline-uri Jenkins executate cu succes
* Imaginile urcate în DockerHub
* Deploy activ în Minikube (dacă este pornit)
* Terraform state salvat în S3 LocalStack

---

## ℹ️ Informații adiționale

* Fișierele `Dockerfile` sunt configurate să monteze volume pentru păstrarea logurilor.
* `terraform.tfstate` este salvat într-un bucket S3 simulat local.
* Instanțele EC2 din LocalStack sunt doar simulate — nu pot fi SSH-uite.

---

## ✍️ Autori

* Victor Tulbure

## 📝 Licență

MIT License
