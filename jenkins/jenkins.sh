#!/bin/bash

# Jenkins
sudo apt update -y
sudo hostnamectl set-hostname jenkins
sudo su ubuntu
sudo apt-get install default-jdk -y
java -version
sudo apt install maven -y
mvn --version
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y


# Install Terraform
echo "Installing Terraform..."
sudo apt install unzip -y

# Import HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
# Add Terraform repository to sources list
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# Update package lists
sudo apt-get update
# Get the latest version of Terraform available
TERRAFORM_LATEST_VERSION=$(apt-cache madison terraform | awk '{print $3}' | sort -V | tail -1)
echo "Latest Terraform version available: ${TERRAFORM_LATEST_VERSION}"
# Install the latest version of Terraform
sudo apt-get install "terraform=${TERRAFORM_LATEST_VERSION}"