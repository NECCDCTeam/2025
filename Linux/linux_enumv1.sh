#!/bin/bash

get_machine_name(){
	hostname
}

get_all_ip_info(){
	ip addr show
}

get_installed_programs(){

	echo "Installed Programs/Apps:"	

	if command -v dpkg &> /dev/null; then
		echo "Programs (dpkg - Debian based):"
		dpkg -l
		echo ""
	fi 

	if command -v rpm &> /dev/null; then
		echo "Programs (rpm - Red hat-based):"
		rpm -qa
		echo ""
	fi 

	if command -v pacman &> /dev/null; then
		echo "Programs (pacman - Arch-based):"
		pacman -Q
		echo ""
	fi

	if command -v apk &> /dev/null; then
		echo "Programs (apk - Alpine Linux):"
		apk info
		echo ""
	fi

	if command -v emerge &> /dev/null; then
		echo "Programs (emerge - Gentoo):"
		emerge --list
		echo ""
	fi

	if command -v zypper &> /deb/null; then
		echo "Programs (zypper openSUSE):"
		zypper se --installed-only
		echo ""
	fi

	if command -v snap &> /dev/null; then
		echo "Programs (snap):"
		snap list
		echo ""
	fi

	if command -v flatpak &> /dev/null; then
		echo "Programs (flatpak):"
		flatpak list --columns=application
		echo ""
	fi

	if command -v brew &> /dev/null; then
		echo "Programs (brew - Homebrew for Linux):"
		brew list
		echo ""
	fi

	if command -v nix &> /dev/null; then
		echo "Programs (nix):"
		nix-env -q
		echo ""
	fi


	echo "Package scan complete."
}

get_os_version(){
	echo "Server OS and Version:"
	
	if [ -f /etc/os-release ]; then
		echo "From /etc/os-release:"
		cat /etc/os-release
	elif [ -f /etc/lsb-release ]; then
		echo "From /etc/lsb-release:"
		cat /etc/lsb-release
	elif [ -f /etc/redhat-release ]; then
		echo "From /etc/redhat-release:"
		cat /etc/redhat-release
	elif [ -f /etc/issue ]; then
		echo "From /etc/issue:"
		cat /etc/issue
	else
		echo "Could not determine OS from known release files."
	fi

	echo ""
	echo "Kernel and Architecture Info:"
	uname -a

	echo ""
	echo "Processor Architecture"
	if command -v lscpu &> /dev/null; then
		lscpu | grep 'Architecture'
	elif [ -f /proc/cpuinfo ]; then
		grep 'model name' /proc/cpuinfo | uniq
	else
		echo "Could not determine CPU architecture."
	fi

	echo ""
	echo "System Uptime:"
	if command -v uptime &> /dev/null; then
		uptime
	else
		cat /proc/uptime |awk '{print $1}' | xargs printf "Uptime: %.2f seconds\n"
	fi

	echo ""
}


get_system_time(){
	echo "System Time"

	if command -v date &> /dev/null; then
		echo "Local Time: $(date)"
		echo "UTC Time:   $(date -u)"
	else
		echo "The Date command is not available"
	fi

	if command -v timedatectl &> /dev/null; then
		echo ""
		echo "Timedatectl Output:"
		timedatectl
	fi

	echo ""
}

get_all_services(){
	echo "Server Roles and Features:"

	if command -v systemctl &> /dev/null; then
		echo "Using systemd services:"
		systemctl list-units --type=service --all
	elif command -v service &> /dev/null; then
		echo "Using SysVinit services:"
		service --status-all 2>&1 | grep -E '\[ \+ \]|\[ \- \]'
	elif command -v rc-status &> /dev/null; then
		echo "Using OpenRC services:"
		rc-status --all
	else
		echo "Unable to determine server roles and features. No recognized service manager found."
	fi

	echo ""
}

get_active_services() {
    echo "Active/Running Services:"

    if command -v systemctl &> /dev/null; then
        systemctl list-units --type=service --state=running
    elif command -v service &> /dev/null; then
        # Extract only active services from SysVinit
        service --status-all 2>&1 | grep '\[ \+ \]' | awk '{print $NF}'
    elif command -v rc-status &> /dev/null; then
        # Extract active services from OpenRC
        rc-status --all | grep "started"
    else
        echo "No recognized service manager found to list active services."
    fi

    echo ""
}

get_filtered_ip(){
	echo "Filtered Network Information"

	ipv4_addresses=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
	ipv6_addresses=$(ip -6 addr show | grep -oP '(?<=inet6\s)[\da-f:]+(?=/)' | grep -v '^fe80')
	mac_addresses=$(ip link show | grep -oP '(?<=link/ether\s)[\da-f:]{17}')
	
	echo -e "\nIPv4 Addresses:\n $ipv4_addresses"
	echo -e "\nIPv6 Addresses:\n $ipv6_addresses"
	echo -e "\nMAC Address:\n    $mac_addresses"
}

find_active_connections() {
        if command -v netstat > /dev/null; then
                echo "using netstat"
                netstat -tunap | awk '
                BEGIN{print "Proto\tLocal Address\t\tRemote Address\t\tState\t\tPID/Program"}
                /Proto/ {next}
                {printf "%-6s %-22s %-22s %-14s %-20s\n", $1, $4, $5, $6, $7}'

        elif command -v ss > /dev/null; then
                echo "using ss"
                ss -tunap | awk '
                BEGIN {print "Proto\t\Local Address\t\tRemote Address\t\tState\t\tPID/Program"}
                NR>1 {printf "%-6s %-22s %-22s %-14s %-20s\n", $1, $5, $6, $2, $7}'

        else
                return 1
        fi
}

