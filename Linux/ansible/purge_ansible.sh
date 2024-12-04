#!/bin/bash

# Function to confirm user intent
confirm() {
    read -p "Are you sure you want to purge all Ansible data from this machine? [y/N]: " choice
    case "$choice" in 
        y|Y ) echo "Proceeding with purge...";;
        * ) echo "Operation cancelled."; exit 1;;
    esac
}

# Confirm the user's intent
confirm

# Remove Ansible installed via pip
echo "Uninstalling Ansible..."
pip3 uninstall -y ansible

# Remove Python packages and dependencies
echo "Removing Python packages and dependencies..."
sudo apt remove -y python3-pip python3-venv python3-dev build-essential sshpass
sudo apt autoremove -y
sudo apt purge -y python3-pip python3-venv python3-dev build-essential sshpass

# Clean up Python cache and Ansible configurations
echo "Cleaning up Python cache and Ansible configurations..."
sudo rm -rf ~/.ansible
sudo rm -rf /etc/ansible
sudo rm -rf /usr/local/lib/python3*/dist-packages/ansible*

# Clean up any remaining Ansible executables
echo "Removing remaining Ansible executables..."
sudo rm -f /usr/local/bin/ansible*
sudo rm -f /usr/bin/ansible*

# Verify Ansible has been removed
echo "Verifying Ansible removal..."
if ! command -v ansible &>/dev/null; then
    echo "Ansible has been successfully removed."
else
    echo "Ansible removal failed. Please check manually."
fi

echo "Purge operation completed."
