#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
	echo "This script must be run as root" >&2
	exit 1
fi

# Check for required commands
REQUIRED_COMMANDS=("useradd" "sudo" "ssh" "sshd")
for cmd in "${REQUIRED_COMMANDS[@]}"; do 
	if ! command -v "$cmd" &>/dev/null; then
		echo "Error: $cmd is not installed. Harass Riley about a fix"
		exit 1
	fi
done

# -------------------------------------------------------------------------
# Variables
USERNAME="ansible_client"
PASSWORD="Y&p_[~Cd^Z}xJ.29Ve,c?Q"
PYTHON_BIN="/usr/bin/python3"
SSH_DIR="/home/$USERNAME/.ssh"
AUTHORIZED_KEYS_FILE="$SSH_DIR/authorized_keys"
SSH_SERVICE="sshd"
# -------------------------------------------------------------------------

# Create the user with a home directory
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

# Install Python 3 if not already installed
if command -v python3 &>/dev/null; then
  echo "Python 3 is already installed."
else
  echo "Installing Python 3..."
  if command -v apt &>/dev/null; then
    apt update && apt install -y python3
  elif command -v yum &>/dev/null; then
    yum install -y python3
  elif command -v dnf &>/dev/null; then
    dnf install -y python3
  elif command -v zypper &>/dev/null; then
    zypper install -y python3
  elif command -v pacman &>/dev/null; then
    pacman -Syu --noconfirm python3
  else
    echo "Package manager not detected. Please install Python 3 manually." >&2
    exit 1
  fi
fi

# Ensure SSH is installed and running
if systemctl is-active --quiet "SSH_SERVICE"; then
	echo "SSH service is running"
else
	echo "Starting SSH Service..."
	systemctl start "$SSH_SERIVE"
	systemctl enable "$SSH_SERVICE"
	echo "SSH service started and enabled"
fi

# Configure SSH for the user
if [ ! -d "$SSH_DIR" ]; then
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
  chown "$USERNAME:$USERNAME" "$SSH_DIR"
  echo "Created SSH directory for $USERNAME."
fi

if [ ! -f "$AUTHORIZED_KEYS_FILE" ]; then
  touch "$AUTHORIZED_KEYS_FILE"
  chmod 600 "$AUTHORIZED_KEYS_FILE"
  chown "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS_FILE"
  echo "Created authorized_keys file for $USERNAME."
fi


# Ensure Python 3 is in PATH
if ! grep -q "$PYTHON_BIN" <<< "$PATH"; then
  echo "Adding Python 3 to PATH..."
  export PATH="$PATH:$PYTHON_BIN"
  echo "export PATH=\"\$PATH:$PYTHON_BIN\"" >> /etc/profile
fi

echo "Setup complete. User $USERNAME with root privileges created, and Python 3 installed."
