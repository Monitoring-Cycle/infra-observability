#!/bin/bash
set -e  # Encerra o script em caso de erro

# Atualiza pacotes e instala dependências
sudo apt update -y
sudo apt install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common

# Cria diretório para chaves GPG
sudo install -m 0755 -d /etc/apt/keyrings

# Adiciona a chave oficial do Docker
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Adiciona o repositório do Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualiza o apt para reconhecer o novo repositório
sudo apt update -y

# Instala Docker, Docker Compose e ferramentas adicionais
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin git vim nano

# Habilita e inicia o Docker
sudo systemctl enable docker
sudo systemctl start docker

# Adiciona o usuário ubuntu ao grupo Docker para evitar problemas de permissão
sudo usermod -aG docker ubuntu

# Instala Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# Instala Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Instala kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Instala o CLI do ArgoCD
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Iniciar o cluster Minikube
minikube start --driver=docker

# Executa como root para clonar o repositório
sudo -i <<EOF

# Define o diretório onde o repositório será clonado
PROJECT_DIR="/home/ubuntu/observability-stack"

# Clona o repositório na EC2
cd /home/ubuntu/
git clone https://github.com/Monitoring-Cycle/infra-observability.git

# Define permissões corretas para evitar problemas de acesso
chown -R ubuntu:ubuntu \$PROJECT_DIR

EOF

# Reinicia o Docker para garantir que todas as permissões e configurações estão aplicadas
sudo systemctl restart docker
