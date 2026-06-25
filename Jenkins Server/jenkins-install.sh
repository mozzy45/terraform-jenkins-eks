#!/bin/bash

# 1. Update system packages
sudo dnf update -y

# 2. Install Java 21 (Now required for modern Jenkins)
sudo dnf install java-21-amazon-corretto-devel -y

# 3. Add Jenkins Repository and Import the modern 2026 Key
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2026.key

# 4. Install and start Jenkins
sudo dnf install jenkins -y
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# 5. Install Git
sudo dnf install git -y

# 6. Install Terraform
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo dnf -y install terraform

# 7. Install kubectl globally
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl