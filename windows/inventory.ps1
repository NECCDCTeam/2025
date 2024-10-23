# Get credentials
$credentials = Get-Credential -Message "Enter a set of domain administrator credentials"

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Get all Windows computers in the domain
$computers = Get-ADComputer -Filter * -Properties * -Credential $credentials

# Get desktop path
$desktopPath = [Environment]::GetFolderPath("Desktop")
$outputFolder = Join-Path $desktopPath "WindowsInventory"

# Create folder on C: drive of each remote machine
$remoteFolderPath = "C:\WindowsInventory"
if (!(Test-Path $remoteFolderPath)) {
    New-Item -ItemType Directory -Path $remoteFolderPath
}

# Create output folder
if (!(Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder
}

# Loop through each computer
foreach ($computer in $computers) {
    if ($computer.OperatingSystem -like "*Windows*") {
        # Create computer-specific folder
        $computerFolder = Join-Path $outputFolder $computer.Name
        if (!(Test-Path $computerFolder)) {
            New-Item -ItemType Directory -Path $computerFolder
        }

        # Create folder on remote machine's C: drive
        Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock {
            $remoteFolderPath = "C:\WindowsInventory"
            if (!(Test-Path $remoteFolderPath)) {
                New-Item -ItemType Directory -Path $remoteFolderPath
            }
        }
    
        # Get IP address info
        $ipInfo = Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock {
            $activeNic = Get-NetAdapter | Select-Object -ExpandProperty IfIndex
            [ordered]@{
                "Hostname"        = $env:COMPUTERNAME
                "IPv4 Address"    = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.ifIndex -eq $activeNic} | Select-Object -ExpandProperty IPAddress)
                "IPv6 Address"    = (Get-NetIPAddress -AddressFamily IPv6 | Where-Object { $_.ifIndex -eq $activeNic} | Select-Object -ExpandProperty IPAddress)
                "MAC Address"     = (Get-NetAdapter | Select-Object -ExpandProperty MacAddress)
            }
        }

        # Get operating system details
        $operatingSystem = $computer.OperatingSystem

        # Get services information
        $servicesInfo = Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock {
            Get-Service | Select-Object -Property Name, DisplayName, StartType, Status
        }

        # Get Installed Programs
        $InstalledPrograms = Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock {
            Get-Package | Select-Object -Property Name, Version, ProviderName
        }

        # Get time sync info
        $TimeInfo = Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock {
            $CurrentDateTime = Get-Date
            $TimeStatus = w32tm /query /status | Select-String ReferenceId, Last, Source
            $formattedTimeStatus = $TimeStatus -join "`n"
            "$($CurrentDateTime)`n$formattedTimeStatus"
        }

        # Get Server Roles, Features, and Capabilities
        $RolesFeaturesCapabilities = ""

        if ($productType -eq 1) {
            # For client OS (ProductType = 1), get only Windows Capabilities
            $installedWindowsCapabilities = Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock {
                Get-WindowsCapability -Online | Where-Object { $_.State -eq "Installed" } | Select-Object -ExpandProperty Name
            }
            
            # Add capabilities to the consolidated string
            $RolesFeaturesCapabilities = $installedWindowsCapabilities -join "`n"
            
        } else {
            # For server OS get both Roles and Features and Windows Capabilities
            $installedRolesAndFeatures = Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock {
                Get-WindowsFeature | Where-Object { $_.InstallState -eq "Installed" } | Select-Object -ExpandProperty DisplayName
            }
            $installedWindowsCapabilities = Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock {
                Get-WindowsCapability -Online | Where-Object { $_.State -eq "Installed" } | Select-Object -ExpandProperty Name
            }
            
            # Combine roles/features and capabilities into the consolidated string
            $RolesFeaturesCapabilities = $installedRolesAndFeatures -join "`n"
            $RolesFeaturesCapabilities += "`n-----------------------------Windows Capabilities-----------------------------`n"
            $RolesFeaturesCapabilities += $installedWindowsCapabilities -join "`n"
        }

        # Save network and system info to file
        [PSCustomObject]@{
            "Host Name"            = $ipInfo.Hostname
            "Operating System"     = $operatingSystem
            "IPv4 Address"         = $ipInfo."IPv4 Address"
            "IPv6 Address"         = $ipInfo."IPv6 Address"
            "MAC Address"          = $ipInfo."MAC Address"
        } | Export-Csv -Path (Join-Path $computerFolder "NetworkAndSystemInfo.csv") -NoTypeInformation 

        # Save services info to file
        $servicesInfo | Export-Csv -Path (Join-Path $computerFolder "Services.csv") -NoTypeInformation 

        # Save installed programs to file
        $InstalledPrograms | Export-Csv -Path (Join-Path $computerFolder "InstalledPrograms.csv") -NoTypeInformation    

        # Save Time info into file
        Out-File -InputObject $TimeInfo -FilePath (Join-Path $computerFolder "TimeZoneInfo.txt")

        # Export Roles, Features, and Capabilities to a CSV with one column
        $csvPath = Join-Path $computerFolder "$($computer.Name)-RolesFeaturesCapabilities.csv"

        [PSCustomObject]@{
            "RolesAndFeatures" = $RolesFeaturesCapabilities
        } | Export-Csv -Path $csvPath -NoTypeInformation
    }
}
