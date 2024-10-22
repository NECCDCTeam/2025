#!/bin/bash

# Function to add bold and color
bold_red="\e[1;31m"
bold_green="\e[1;32m"
bold_yellow="\e[1;33m"
bold_blue="\e[1;34m"
bold_white="\e[1;37m"
reset="\e[0m"

display_active_services() {
    echo -e "${bold_blue}Active/Running Services:${reset}"
    if command -v systemctl &> /dev/null; then
        echo -e "${bold_green}"
        systemctl list-units --type=service --state=running
    elif command -v service &> /dev/null; then
        echo -e "${bold_green}"
        service --status-all 2>&1 | grep '\[ \+ \]' | awk '{print $NF}'
    elif command -v rc-status &> /dev/null; then
        echo -e "${bold_green}"
        rc-status --all | grep "started"
    else
        echo -e "${bold_red}No recognized service manager found to list active services.${reset}"
    fi
    echo -e "${reset}"
}

get_filtered_ip() {
    echo -e "${bold_blue}Filtered Network Information${reset}"

    # Get IPv4 addresses and their interfaces
    ipv4_info=$(ip -4 addr show | grep -oP '^\d+: \K[^:]+|(?<=inet\s)\d+(\.\d+){3}')
    # Get IPv6 addresses and their interfaces, excluding link-local addresses (fe80::)
    ipv6_info=$(ip -6 addr show | grep -oP '^\d+: \K[^:]+|(?<=inet6\s)[\da-f:]+(?=/)' | grep -v '^fe80')
    # Get MAC addresses and their interfaces
    mac_info=$(ip link show | grep -oP '^\d+: \K[^:]+|(?<=link/ether\s)[\da-f:]{17}' | paste -d' ' - -)


    # Check if any addresses were found, and handle cases where they may be empty
    if [ -z "$ipv4_info" ]; then
        ipv4_info="No IPv4 addresses found"
    fi

    if [ -z "$ipv6_info" ]; then
        ipv6_info="No IPv6 addresses found"
    fi

    if [ -z "$mac_info" ]; then
        mac_info="No MAC addresses found"
    fi

    echo -e "${bold_yellow}IPv4 Addresses and Interfaces:${reset}"
    echo -e "$ipv4_info" | sed -n 'N;s/\n/ - /p'  # Pair interface and IP address

    echo -e "${bold_yellow}\nIPv6 Addresses and Interfaces:${reset}"
    echo -e "$ipv6_info" | sed -n 'N;s/\n/ - /p'  # Pair interface and IP address

    echo -e "${bold_yellow}\nMAC Addresses and Interfaces:${reset}"
    echo -e "$mac_info" | sed -n 'N;s/\n/ - /p'  # Pair interface and MAC address

    echo -e "\n"
}

get_machine_name() {
    echo -e "${bold_blue}Machine Name:${reset}"
    echo -e "$(hostname)\n"
}

get_os_version() {
    echo -e "${bold_blue}Server OS and Version:${reset}"

    if [ -f /etc/os-release ]; then
        echo -e "${bold_yellow}From /etc/os-release:${reset}"
        cat /etc/os-release
    elif [ -f /etc/lsb-release ]; then
        echo -e "${bold_yellow}From /etc/lsb-release:${reset}"
        cat /etc/lsb-release
    elif [ -f /etc/redhat-release ]; then
        echo -e "${bold_yellow}From /etc/redhat-release:${reset}"
        cat /etc/redhat-release
    elif [ -f /etc/issue ]; then
        echo -e "${bold_yellow}From /etc/issue:${reset}"
        cat /etc/issue
    else
        echo "Could not determine OS from known release files."
    fi

    echo ""
    echo -e "${bold_blue}Kernel and Architecture Info:${reset}"
    uname -a

    echo ""
    echo -e "${bold_blue}Processor Architecture:${reset}"
    if command -v lscpu &> /dev/null; then
        lscpu | grep 'Architecture'
    elif [ -f /proc/cpuinfo ]; then
        grep 'model name' /proc/cpuinfo | uniq
    else
        echo "Could not determine CPU architecture."
    fi

    echo ""
    echo -e "${bold_blue}System Uptime:${reset}"
    if command -v uptime &> /dev/null; then
        uptime
    else
        cat /proc/uptime | awk '{print $1}' | xargs printf "Uptime: %.2f seconds\n"
    fi

    echo ""
}

get_system_time() {
    echo -e "${bold_blue}System Time:${reset}"

    if command -v date &> /dev/null; then
        echo -e "${bold_yellow}Local Time:${reset} $(date)"
        echo -e "${bold_yellow}UTC Time:${reset}   $(date -u)"
    else
        echo "The Date command is not available"
    fi

    if command -v timedatectl &> /dev/null; then
        echo ""
        echo -e "${bold_yellow}Timedatectl Output:${reset}"
        timedatectl
    fi

    echo ""
}

get_installed_programs() {
    echo -e "${bold_blue}Installed Programs/Apps${reset}"
    
    if command -v dpkg &> /dev/null; then
        echo -e "${bold_yellow}Programs (dpkg - Debian based):${reset}"
        dpkg -l
        echo -e "\n"
    fi

    if command -v rpm &> /dev/null; then
        echo -e "${bold_yellow}Programs (rpm - Red hat-based):${reset}"
        rpm -qa
        echo -e "\n"
    fi

    if command -v pacman &> /dev/null; then
        echo -e "${bold_yellow}Programs (pacman - Arch-based):${reset}"
        pacman -Q
        echo -e "\n"
    fi

    if command -v apk &> /dev/null; then
        echo -e "${bold_yellow}Programs (apk - Alpine Linux):${reset}"
        apk info
        echo -e "\n"
    fi

    if command -v emerge &> /dev/null; then
        echo -e "${bold_yellow}Programs (emerge - Gentoo):${reset}"
        emerge --list
        echo -e "\n"
    fi

    if command -v zypper &> /dev/null; then
        echo -e "${bold_yellow}Programs (zypper - openSUSE):${reset}"
        zypper se --installed-only
        echo -e "\n"
    fi

    if command -v snap &> /dev/null; then
        echo -e "${bold_yellow}Programs (snap):${reset}"
        snap list
        echo -e "\n"
    fi

    if command -v flatpak &> /dev/null; then
        echo -e "${bold_yellow}Programs (flatpak):${reset}"
        flatpak list --columns=application
        echo -e "\n"
    fi

    if command -v brew &> /dev/null; then
        echo -e "${bold_yellow}Programs (brew - Homebrew for Linux):${reset}"
        brew list
        echo -e "\n"
    fi

    if command -v nix &> /dev/null; then
        echo -e "${bold_yellow}Programs (nix):${reset}"
        nix-env -q
        echo -e "\n"
    fi

    echo -e "${bold_green}Package scan complete.${reset}\n"
}

find_active_connections() {
    echo -e "${bold_blue}Active Network Connections${reset}"

    if command -v netstat &> /dev/null; then
        echo -e "${bold_yellow}Using netstat:${reset}"
        netstat -tunap | awk '
        BEGIN{print "Proto\tLocal Address\t\tRemote Address\t\tState\t\tPID/Program"}
        /Proto/ {next}
        {printf "%-6s %-22s %-22s %-14s %-20s\n", $1, $4, $5, $6, $7}'
    elif command -v ss &> /dev/null; then
        echo -e "${bold_yellow}Using ss:${reset}"
        ss -tunap | awk '
        BEGIN {print "Proto\tLocal Address\t\tRemote Address\t\tState\t\tPID/Program"}
        NR>1 {printf "%-6s %-22s %-22s %-14s %-20s\n", $1, $5, $6, $2, $7}'
    else
        echo "Neither netstat nor ss is available."
    fi

    echo -e "\n"
}

get_user_info() {
    echo -e "${bold_blue}User Information${reset}"

    echo -e "${bold_yellow}Current User:${reset}"
    if command -v whoami &> /dev/null; then
        whoami
    else
        echo "Unable to determine current user."
    fi

    echo -e "\n${bold_yellow}User ID Information (id command):${reset}"
    if command -v id &> /dev/null; then
        id
    else
        echo "The id command is not available."
    fi

    echo -e "\n${bold_yellow}Logged-in Users (who command):${reset}"
    if command -v who &> /dev/null; then
        who
    else
        echo "The who command is not available."
    fi

    echo -e "\n${bold_yellow}Groups for Current User:${reset}"
    if command -v groups &> /dev/null; then
        groups
    else
        echo "Unable to determine groups for the current user."
    fi

    echo -e "\n"
}

get_all_users_info() {
    echo -e "${bold_blue}All Users Information${reset}"

    # Fetch user information from /etc/passwd
    echo -e "${bold_yellow}User List:${reset}"
    if [ -f /etc/passwd ]; then
        awk -F: '{printf "Username: %-20s UID: %-5s GID: %-5s Home: %-30s Shell: %s\n", $1, $3, $4, $6, $7}' /etc/passwd
    else
        echo "Unable to access user information file."
    fi

    echo -e "\n${bold_yellow}Total Users:${reset}"
    total_users=$(wc -l < /etc/passwd)
    echo "$total_users users found."

    echo -e "\n"
}


main() {
    echo -e "${bold_white}System Enumeration Script:${reset}"
    
    # Call the functions
    get_machine_name
    get_os_version
    get_filtered_ip
    get_system_time
    display_active_services
    find_active_connections
    get_user_info
    get_all_users_info
}

# Execute the main function
main
 
