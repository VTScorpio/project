#!/bin/bash

set -e

# REPO_URL="https://github.com/user/platforma-monitorizare.git"
# CLONE_DIR="$HOME/platforma-monitorizare"

echo "Verificare acces root..."
[[ "$EUID" -ne 0 ]] && { echo "Important access root. Sintaxa sudo ./setup.sh" ;   exit 1; }

echo "Verificare cerinte, instalare si actualizare pachete..."
apt update -y && apt upgrade -y


if ! command -v docker &> /dev/null; then
  echo "🐳 Instalare Docker..."
  apt apt-get install ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable docker
  systemctl start docker
fi

# 3. Instalare Git
if ! command -v git &> /dev/null; then
  echo "Install Git..."
  apt install -y git
fi

# 4. Instalare Python 3 
if ! command -v python3 &> /dev/null; then
  echo "Install Python 3..."
  apt install -y python3
fi

# 4. Instalare Python 3 pip
if ! command -v python3-pip &> /dev/null; then
  echo "Install Python 3 pip ..."
  apt install -y python3-pip
fi

# 5. Instalare Jenkins
if ! systemctl status jenkins &> /dev/null; then
  echo " Instalare Jenkins..."
  wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
  apt update -y
  apt install -y fontconfig openjdk-21-jre jenkins
  java -version
  systemctl enable jenkins
  systemctl start jenkins
fi

# 6. Instalare Ansible
if ! command -v ansible &> /dev/null; then
  echo "📦 Instalare Ansible..."
  apt install -y software-properties-common
  add-apt-repository --yes --update ppa:ansible/ansible
  apt install -y ansible
  ansible --version
fi


# 7. Instalare Terraform
if ! command -v terraform &> /dev/null; then
  echo "Install Terraform..."
  wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  apt update -y
  apt install -y terraform
fi


# # 8. Clonează proiectul
# if [ ! -d "$CLONE_DIR" ]; then
#   echo "⬇️ Clonare repository din GitHub..."
#   git clone "$REPO_URL" "$CLONE_DIR"
# else
#   echo "🔄 Repository deja clonat. Se face pull..."
#   cd "$CLONE_DIR" && git pull
# fi

# # 9. Rulează docker-compose
# cd "$CLONE_DIR"
# echo "🚀 Pornire platformă cu Docker Compose..."
# docker compose up -d

# 10. Afișare detalii Jenkins
echo "Acces Jenkins: http://$(hostname -I | awk '{print $1}'):8080"
echo "Administrator password inițial:"
cat /var/lib/jenkins/secrets/initialAdminPassword

echo "✅ Instalare completă și platformă rulând!"