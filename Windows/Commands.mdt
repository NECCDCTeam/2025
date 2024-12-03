# First 48

Below is a list of things that should be completed as soon as you log onto a machine

- Get the host name
- Get the IP configuration, including MAC address
- Gather all packages (installed programs) (”Add or remove programs”)
- Get the server OS and version
- If it is a server, get the type and roles and features
- View the active connections, i.e., SSH, TCP, and RDP
- Check the system time

## Enumeration

The enumeration command should be run on all machines when you first login

### IP Address, Host Name, and MAC address

- `$env:COMPUTERNAME` → Host name
- `ipconfig`→ IP address information, MAC address

### General

- `Get-Package | Select-Object Name, Version, ProviderName` → Getting all programs for Server 2016 - 2022
- `Get-CimInstance -ClassName Win32_Product | Select-Object Name, Vendor, Version` → Getting all programs for Server 2012
- `(Get-WmiObject Win32_OperatingSystem).Caption` → Get server version and OS
- `Get-windowsFeature | Where-Object { $_.InstallState -eq "Installed"} | Select-Object -ExpandProperty DisplayName` → Getting installed Windows features
- `Get-WindowsCapability -Online | Where-Object {$_.State -eq "Installed"} | Select-Object -ExpandProperty Name` → Getting installed Windows capabilities
- `Get-FileShare | Select-Object -ExpandProperty Name` → Getting file shares

### Connections

- `Get-NetTCPConnection | Where-Object { $_.State -eq "Listen"} | Select-Object LocalPort` → Getting local listening ports
- `Get-CimInstance -ClassName Win32_Process -Filter "Name = 'sshd.exe'" | Get-CimAssociatedInstance -Association Win32_SessionProcess | Get-CimAssociatedInstance -Association Win32_LoggedOnUser | Where-Object {$_.Name -ne 'SYSTEM'}` → finding currently active SSH sessions
- `quser /server:<server-name>`  OR `quser` - Find certain connections
- `logoff <id>` Logoff a particular session discovered in quser

### Local Accounts

- `Get-CimInstance -ClassName Win32_UserAccount` → Getting local accounts on Windows 7, Server 2012
- `Get-LocalUser | Select-Object Name, Enabled, Description` → Getting local accounts on Windows 10, Server 2016 - 2022

### Time

`Net Time` → Checking which server the time is coming from

`Net Time \\hackmepower.local /SET /YES` → This command sgetetsNe the time with that of the domain

## Remediation

### Resetting a local user password

```powershell
#Code skeleton
Set-LocalUser -Name <User Account Name> -Password (ConvertTo-SecureString -AsPlainText "<Your Password>" -Force)

#Code with real example
Set-LocalUser -Name MrHappyFace -Password (ConvertTo-SecureString -AsPlainText "password1234!@#$" -Force)

# Notes on the above code
Ensure you replace the text inside the carats and the carat characters themselves. The carats are just placeholders
```

## Disable and remove PowerShell history

```powershell
del "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" # Delete current file

Set-Content -Path $Profile -Value "Set-PSReadlineOption -HistorySaveStyle SaveNothing" # Disable saving history

```

# Certificates

# Web Server Configuration

```bash
# Find running service 
service apache2 status
# Install openssl 
sudo apt-get install openssl
# Set up cert 
mkdir ~/certs
cd ~/certs
openssl genrsa -out <name>.key 2048
openssl req -new -sha256 -key <name>.key -out <name>.csr

```

# CA Configuration

Copy the .csr file from Linux to Windows (I recommend WinSCP for this)

```powershell
# Req CA 
certreq -submit -attrib "CertificateTemplate:WebServer" <machine-ip>.csr <machine-ip>.cer
```
