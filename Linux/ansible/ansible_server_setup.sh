# This is the ansible setup script
# This should be run as the user that is going to be running ansible

# Generate SSH Key Pair
SSH_KEY="$HOME/.ssh/id_rsa"
if [ ! -f "$SSH_KEY" ]; then
  echo "Generating SSH key pair..."
  ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N ""
  echo "SSH key pair generated at $SSH_KEY"
else
  echo "SSH key pair already exists at $SSH_KEY"
fi

# Hardcoded
HARD_CODED_U="ansible_client"
HARD_CODED_P="Y&p_[~Cd^Z}xJ.29Ve,c?Q"
HOSTS_FILE="./hosts"

# Enusre ansible hosts file exists
if [ ! -f "$HOSTS_FILE" ]; then
    echo "Creating hosts file at $HOSTS_FILE..."
    echo "[all]" > "$HOSTS_FILE"
    echo "Hosts file created."

copy_ssh_key() {
    local client_ip="$1"
    echo "User: $HARD_CODED_U, Password: $HARD_CODED_P, Client IP: $client_ip"
    
    echo "Copying SSH public key to $HARD_CODED_U@$client_ip..."
    sshpass -p "$HARD_CODED_P" ssh-copy-id -o StrictHostKeyChecking=no "$HARD_CODED_U@$client_ip"
    
    if [ $? -eq 0 ]; then
        echo "SSH key successfully copied to $HARD_CODED_U@$client_ip"
    else
        echo "Failed to copy SSH key to $HARD_CODED_U@$client_ip. Please check your connection or credentials."
    fi
}

# Prompt for client IP and copy key
while true; do
        read -p "Enter client IP (or type 'done' to finish): " client_ip
        if [ "$client_ip" = "done" ]; then
                break
        fi

        copy_ssh_key "$client_ip"

        # Check if the client IP already exists in the hosts file
        if ! grep -q "$client_ip" "$HOSTS_FILE"; then
                # Add the client to the hosts file
                echo "Adding $client_ip to hosts file..."
                echo "$client_ip ansible_user=ansible_client ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_python_interpreter=/usr/bin/python3" >> "$HOSTS_FILE"
                echo "$client_ip added to hosts file."
        else
                echo "$client_ip already exists in hosts file."
        fi
done
