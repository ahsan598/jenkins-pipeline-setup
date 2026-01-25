#!/bin/bash

# ===========================================================
# Docker Installation Script for Ubuntu Instances
# Compatible with Ubuntu 20.04, 22.04, 24.04
# Installs Docker Engine, CLI, Containerd, Buildx & Compose
# ===========================================================

# Update package list
sudo apt update

# Install required dependencies
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Setup Docker official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Update package list again to include Docker packages
sudo apt update

# Install Docker Engine, CLI, containerd, Buildx, Compose
sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
