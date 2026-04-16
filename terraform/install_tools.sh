#!/bin/bash

set -e

echo "🔄 Updating system..."
sudo apt update -y

echo "☕ Installing Java 21 (Required for Jenkins)..."
sudo apt install -y fontconfig openjdk-21-jre

java -version

# ---------------- JENKINS INSTALL ----------------
echo "🔑 Adding Jenkins key..."
sudo mkdir -p /etc/apt/keyrings

wget -O /tmp/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
sudo mv /tmp/jenkins-keyring.asc /etc/apt/keyrings/jenkins-keyring.asc

echo "📦 Adding Jenkins repo..."
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y

echo "🚀 Installing Jenkins..."
sudo apt install -y jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins

# ---------------- DOCKER INSTALL ----------------
echo "🐳 Installing Docker..."
sudo apt install -y docker.io

sudo systemctl enable docker
sudo systemctl start docker

echo "👤 Adding users to Docker group..."
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins

sudo newgrp docker

# ---------------- TRIVY INSTALL (UPDATED METHOD) ----------------
echo "🔐 Installing Trivy..."

sudo mkdir -p /etc/apt/keyrings
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
  sudo tee /etc/apt/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list

sudo apt update -y
sudo apt install -y trivy

# ---------------- AWS CLI ----------------
echo "☁️ Installing AWS CLI..."
sudo snap install aws-cli --classic

# ---------------- HELM ----------------
echo "⛵ Installing Helm..."
sudo snap install helm --classic

# ---------------- KUBECTL ----------------
echo "☸️ Installing Kubectl..."
sudo snap install kubectl --classic

# ---------------- FINAL ----------------
echo "🔄 Restarting services..."
sudo systemctl restart docker
sudo systemctl restart jenkins

echo "🎉 Setup Completed!"

echo "🌐 Access Jenkins: http://<your-server-ip>:8080"
echo "🔐 Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "⚠️ IMPORTANT: Logout & login again for Docker group to apply"