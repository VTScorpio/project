# 📦 Platforma de Backup si Monitorizare - Proiect DevOps

## 🔍 Descriere generala

Acest proiect DevOps este o platforma modulara ce asigura:

* **Backup automat** al starii sistemului (load, memorie, disk etc.).
* **Monitorizare periodica** cu loguri salvate persistent.
* **Ansible** automatizare.
* **CI/CD complet** folosind **Jenkins**.
* **Containere Docker** pentru izolare.
* **Deploy local in Minikube** (opțional).
* **Provisionare infrastructura AWS local cu LocalStack** prin **Terraform**.

## 📁 Structura proiectului

```
project/
.
├── ansible
│   ├── install-docker.yml
│   ├── inventory.ini
│   ├── run-platform.yml
│   ├── start-platform.yml
│   └── stop-platform.yml
├── ansible.sh
├── backup
│   ├── backup.py
│   ├── Dockerfile
│   └── test_backup.py
├── backup-data  
├── data  
├── docker-compose.yml
├── docker.sh
├── Jenkins
│   ├── backup
│   │   └── Jenkinsfile
│   └── mon
│       └── Jenkinsfile
├── k8s
│   ├── backup-deployment.yaml
│   ├── backup-service.yaml
│   ├── monitor-deployment.yaml
│   └── monitor-service.yaml
├── k8s.sh
├── mon
│   ├── Dockerfile
│   └── mon.sh
├── README.md
├── terraform
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── variables.tf
└── tf.sh
```

## Instalare si rulare locala

### Cerințe minime:

* SSH
* Python 3.8+
* Docker
* Docker compose
* Ansible
* Jenkins
* Minikube (opțional)
* Terraform
* LocalStack (versiune full)
* AWS
* Masina virtuala access SSH

### 1. Cloneaza proiectul

```bash
git clone https://github.com/VTScorpio/project.git
cd project
```

### 2. Containere Docker

* Rulare script monitor si backup Bash

```bash
sudo ./docker.sh start # pornire containere mon si backup
sudo ./docker.sh stop  # oprire containere mon si backup
```
* In directorul data dupa pornire se suprascrie conținutul fisierului system-state.log.
* In directorul backup-data dupa pornire se efectueaza backup-ul fisierului  system-state.log doar daca fisierul s-a modificat.

### 3. Ansible

* Pentru functionare corecta este important sa fie efectuata conexiunea prin ssh  cu masina virtula remote.

```bash
./ansible.sh start     # pornire proces de instalare docker si copiere fisiere proiect
./ansible.sh stop       # oprire containere docker de pe masina virtuala remote  
./ansible install       # pornire proces de instalare docker si docker compose
```
* Se verifica pe masina remote daca a pornit containerele docker


### 4. CI/CD cu Jenkins

* Pentru functionare corecta este important:
* Sa fie create credentialele pentru conexiunea hub.docker.com  cu ID dockerhub.

#### Creati Utilizator si View dedicat:

* User: `ex-project`
* View: pattern `^project-.*`

#### Creati 2 pipeline :
* Creati 2 Pipeline project-mon si 	project-backup, selectare script from SCM ->  GIT. 
* Indicati -> Repository URL -> https://github.com/VTScorpio/project. 
* Indicati -> Branch Specifier (blank for 'any') -> */main.
* Indicati -> Script Path Jenkins/mon/Jenkinsfile pentru monitor si Jenkins/backup/Jenkinsfile pentru backup

#### Pipeline Bash (`/Jenkins/mon/Jenkinsfile`):

* Docker build
* Push în DockerHub
* Start kubectl monitor
 
#### Pipeline Python (`/Jenkins/backup/Jenkinsfile`):

* Docker build
* Push în DockerHub
* Start kubectl backup

### Pentru verificare cu pipeline Jenkins + Deploy în Minikube (opțional) :

#### De obicei Jenkins ruleaza ca alt user (ex: jenkins), este necesar de verificat:

```bash
minikube update-context
kubectl config current-context # daca vezi -> minikube e bine,  daca nu atunci executa urmatoarea comanda:
kubectl config use-context minikube
```

#### Creeaza directorul .kube si .minikube pentru jenkins

```bash
sudo mkdir -p /var/lib/jenkins/.kube
sudo mkdir -p /var/lib/jenkins/.minikube
```

#### Copiaza fisierul config si fisierele de certificare

```bash
sudo cp  $HOME/.kube/config /var/lib/jenkins/.kube/
sudo cp -r  $HOME/.minikube/* /var/lib/jenkins/.minikube/
```

#### Schimba ownerul la fisiere pentru userul Jenkins

```bash
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
sudo chown -R jenkins:jenkins /var/lib/jenkins/.minikube
```

#### Schimba calea pentru userul Jenkins

```bash
sudo nano /var/lib/jenkins/.kube/config  # Inlocuieste toate aparitiile lui: * $HOME/.minikube/ in /var/lib/jenkins/.minikube/
```
* Rulati pipeline

####  Deploy în Minikube  (opțional) 

* Pentru verificare fara pipeline Jenkins:

```bash
./k8s.sh start # pornire proces
./k8s.sh stop  # oprire proces
```

### 5. Provisionare AWS, Localstack cu Terraform

* Pentru verificare script Terraform utilizati:

```bash
./tf.sh start
./tf.sh stop
```

#### ℹInformații adiționale

* `terraform.tfstate` este salvat într-un bucket S3 simulat local.
* Instanțele EC2 din LocalStack sunt doar simulate — nu pot fi SSH-uite.

## Autori

* Victor Tulbure

## Licența

* MIT License
