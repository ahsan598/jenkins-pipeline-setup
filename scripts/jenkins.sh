#!/bin/bash

# =======================================================
# Jenkins Installation Script for Ubuntu Instances
# Compatible with Ubuntu 20.04, 22.04, 24.04
# Includes Java (OpenJDK 21) setup and Jenkins LTS repo
# =======================================================

# Update package list
sudo apt update

# Install Java (Jenkins dependency)
sudo apt install openjdk-21-jdk -y

# Download Jenkins GPG key
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

# Add Jenkins repository to package manager sources
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update apt sources
sudo apt update

# Install Jenkins
sudo apt install jenkins -y
