apt-get update
apt-get install -y git

# Install Docker
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the user to the docker group
sudo usermod -aG docker vagrant

# Apply the changes
newgrp docker

# pull sonarqube, postgres, prometheus, grafana, jenkins and docker:dind
docker pull sonarqube
docker pull postgres
docker pull prom/prometheus
docker pull grafana/grafana
docker pull josemokeni/jenkins-trivy
docker pull docker:dind

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# minikube start 
minikube start --driver=docker

# start /shared/docker-compose.yml
docker-compose -f /shared/docker-compose.yml up -d

# git configuration
git config --global user.name "Jose Mokeni"
git config --global user.email "jmmokeni@gmail.com"

ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1

eval "$(ssh-agent -s)"

ssh-add ~/.ssh/id_rsa