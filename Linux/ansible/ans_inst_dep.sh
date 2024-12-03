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

# Create the new control user
USERNAME="Playbook_King"
PASSWORD="V~4y5z@&_#*TJnL8G]R("

if id "$USERNAME" &>/dev/null; then
        echo "User $USERNAME already exists"
else
        useradd -m -s /bin/bash "$USERNAME"
        echo "$USERNAME:$PASSWORD" | chpasswd
        echo "User $USERNAME created and password set."
fi

# Add the user to the sudoers file for root privileges
if grep -q "$USERNAME" /etc/sudoers; then
  echo "User $USERNAME already has sudo privileges."
else
  echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
  echo "User $USERNAME granted sudo privileges."
fi

su - "$USERNAME"

