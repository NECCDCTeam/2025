#!/bin/bash

# Update and upgrade the system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Python and required build tools
echo "Installing Python and dependencies..."
sudo apt install -y python3 python3-pip python3-venv python3-dev build-essential sshpass

# Upgrade pip to the latest version
echo "Upgrading pip..."
python3 -m pip install --upgrade pip

# Install Ansible
echo "Installing Ansible..."
sudo pip install ansible

# Verify installation
echo "Verifying Ansible installation..."
ansible --version
echo "Cleaning up unnecessary packages..."
sudo apt autoremove -y

echo "Ansible installation completed successfully!"
