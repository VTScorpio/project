#!/bin/bash

# Verifică dacă rulează ca root
if [ "$(id -u)" -ne 0 ]; then
    echo "Acest script trebuie rulat ca root (folosește sudo).Ex: sudo $0"
    exit 1
fi

# Actualizează sistemul
echo "Actualizare sistem..."
apt update && apt upgrade -y

# Instalează dependințe generale
apt install -y curl conntrack unzip openjdk-11-jdk python3 python3-pip openssh-client sshpass

# Verifică și instalează sshd (OpenSSH server)
if ! dpkg -l | grep -q openssh-server; then
    echo "OpenSSH server (sshd) nu este instalat. Se instalează acum..."
    apt install -y openssh-server
    systemctl enable ssh
    systemctl start ssh
else
    echo "OpenSSH server (sshd) este deja instalat."
    systemctl enable ssh
    systemctl restart ssh
fi

# Verifică și instalează Docker
if ! command -v docker &> /dev/null; then
    echo "Docker nu este instalat. Se instalează acum..."
    apt install -y docker.io
else
    echo "Docker este deja instalat."
fi

# Activează și pornește Docker
echo "Configurare serviciu Docker..."
systemctl enable docker
systemctl start docker

# Creează grupul docker dacă nu există
if ! getent group docker > /dev/null; then
    echo "Creare grup docker..."
    groupadd docker
fi

# Adaugă toți utilizatorii non-system (UID >=1000 și <65534) la grupul docker
echo "Adăugarea utilizatorilor non-system la grupul docker..."
getent passwd | awk -F: '{ if($3 >= 1000 && $3 < 65534) print $1 }' | while read -r user; do
    usermod -aG docker "$user"
    echo "Utilizatorul $user a fost adăugat la grupul docker."
done

# Verifică și instalează Minikube
if ! command -v minikube &> /dev/null; then
    echo "Minikube nu este instalat. Se instalează acum..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
else
    echo "Minikube este deja instalat."
fi

# Verifică și instalează kubectl
if ! command -v kubectl &> /dev/null; then
    echo "kubectl nu este instalat. Se instalează acum..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install kubectl /usr/local/bin/kubectl
    rm kubectl
else
    echo "kubectl este deja instalat."
fi

# Verifică și instalează Ansible
if ! command -v ansible &> /dev/null; then
    echo "Ansible nu este instalat. Se instalează acum..."
    pip3 install ansible
else
    echo "Ansible este deja instalat."
fi

# Verifică și instalează LocalStack CLI
if ! command -v localstack &> /dev/null; then
    echo "LocalStack nu este instalat. Se instalează acum..."
    pip3 install localstack
else
    echo "LocalStack este deja instalat."
fi

# Verifică și instalează AWS CLI
if ! command -v aws &> /dev/null; then
    echo "AWS CLI nu este instalat. Se instalează acum..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
else
    echo "AWS CLI este deja instalat."
fi

# Configurează AWS CLI pentru LocalStack pentru fiecare utilizator non-system
echo "Configurare AWS CLI pentru LocalStack..."
getent passwd | awk -F: '{ if($3 >= 1000 && $3 < 65534) print $1 }' | while read -r user; do
    echo "Configurare AWS CLI pentru utilizatorul $user..."
    sudo -u "$user" mkdir -p /home/"$user"/.aws
    # Scrie fișierul credentials
    cat > /home/"$user"/.aws/credentials << EOF
[default]
aws_access_key_id = foo
aws_secret_access_key = bar
EOF
    # Scrie fișierul config
    cat > /home/"$user"/.aws/config << EOF
[default]
region = us-east-1
output = json
endpoint_url = http://localhost:4566
EOF
    chown -R "$user":"$user" /home/"$user"/.aws
    chmod 600 /home/"$user"/.aws/credentials /home/"$user"/.aws/config
done

# Pornește LocalStack ca un container Docker
if ! docker ps -q --filter "name=localstack" | grep -q .; then
    echo "Pornire LocalStack ca un container Docker..."
    docker run -d --rm -p 4566:4566 -p 4510-4559:4510-4559 --name localstack localstack/localstack
else
    echo "LocalStack rulează deja."
fi

# Verifică și instalează Terraform
if ! command -v terraform &> /dev/null; then
    echo "Terraform nu este instalat. Se instalează acum..."
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
    echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/terraform.list
    apt update
    apt install -y terraform
else
    echo "Terraform este deja instalat."
fi

# Verifică și instalează Jenkins
if ! systemctl is-active --quiet jenkins; then
    echo "Jenkins nu este instalat. Se instalează acum..."
    curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" > /etc/apt/sources.list.d/jenkins.list
    apt update
    apt install -y jenkins
    systemctl enable jenkins
    systemctl start jenkins
else
    echo "Jenkins este deja instalat și rulează."
fi

# Verifică și instalează Python
if ! command -v python3 &> /dev/null; then
    echo "Python3 nu este instalat. Se instalează acum..."
    apt install -y python3 python3-pip
else
    echo "Python3 este deja instalat."
fi

# Setează permisiuni corecte pentru binare
echo "Setare permisiuni pentru binare..."
chmod 755 /usr/local/bin/minikube /usr/local/bin/kubectl /usr/local/bin/aws /usr/local/bin/terraform
chown root:root /usr/local/bin/minikube /usr/local/bin/kubectl /usr/local/bin/aws /usr/local/bin/terraform

# Configurare SSH pentru host remote
echo "Configurare conexiune SSH către un host remote..."
read -p "Introdu adresa IP a hostului remote: " remote_ip
read -p "Introdu numele de utilizator pentru hostul remote: " remote_user
read -s -p "Introdu parola pentru utilizatorul remote (nu va fi afișată): " remote_pass
echo

# Adaugă hostul la known_hosts și configurează SSH pentru fiecare utilizator non-system
getent passwd | awk -F: '{ if($3 >= 1000 && $3 < 65534) print $1 }' | while read -r user; do
    echo "Configurare SSH pentru utilizatorul $user..."
    sudo -u "$user" mkdir -p /home/"$user"/.ssh
    if [ ! -f /home/"$user"/.ssh/id_rsa ]; then
        sudo -u "$user" ssh-keygen -t rsa -b 4096 -f /home/"$user"/.ssh/id_rsa -N ""
    fi
    chown -R "$user":"$user" /home/"$user"/.ssh
    chmod 700 /home/"$user"/.ssh
    chmod 600 /home/"$user"/.ssh/id_rsa
    SSHPASS="$remote_pass" sudo -u "$user" sshpass -e ssh-copy-id -o StrictHostKeyChecking=no "$remote_user@$remote_ip"
    if [ $? -eq 0 ]; then
        echo "Conexiune SSH configurată cu succes pentru $user către $remote_user@$remote_ip."
    else
        echo "Eroare la configurarea SSH pentru $user. Verifică IP-ul, utilizatorul sau parola."
    fi
done

# Verifică versiunile instalate
echo "Versiuni instalate:"
docker --version
minikube version --short
kubectl version --client --short
ansible --version
localstack --version
aws --version
terraform --version
java -version
echo "Jenkins: $(systemctl is-active jenkins)"
echo "SSHD: $(systemctl is-active ssh)"

# Testează pornirea Minikube ca root (folosind driver Docker)
echo "Testare pornire Minikube..."
minikube start --driver=docker --force

# Verifică accesul la cluster
echo "Verificarea accesului la cluster..."
kubectl cluster-info

# Mesaj final pentru utilizatori
echo "Instalare și configurare complete!"
echo "Toți utilizatorii non-system (UID 1000-65534) au fost adăugați la grupul docker și au acces SSH configurat la $remote_user@$remote_ip."
echo "AWS CLI este configurat pentru LocalStack (endpoint: http://localhost:4566). Testează cu: aws --endpoint-url=http://localhost:4566 s3 ls"
echo "LocalStack rulează pe port 4566. Verifică cu: curl http://localhost:4566/health"
echo "SSHD este activ. Poți accepta conexiuni SSH pe mașina locală (port 22)."
echo "IMPORTANT: Utilizatorii trebuie să se deconecteze și să se reconecteze (sau să ruleze 'newgrp docker') pentru ca permisiunile Docker să aibă efect."
echo "Fiecare utilizator poate rula 'minikube start --driver=docker' pentru a configura propriul cluster local."
echo "Jenkins este accesibil la http://<server-ip>:8080. Verifică /var/lib/jenkins/secrets/initialAdminPassword pentru parola inițială."
echo "Testează conexiunea SSH cu: ssh $remote_user@$remote_ip"
echo "Avertisment: Adăugarea la grupul docker oferă acces potențial elevat; folosește cu atenție în medii sensibile."