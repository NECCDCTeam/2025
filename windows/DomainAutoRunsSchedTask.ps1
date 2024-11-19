# Get credentials
$credentials = Get-Credential -Message "Enter a set of domain administrator credentials"

# Get all Windows computers in the domain
$computers = Get-ADComputer -Filter * -Properties * -Credential $credentials

# Get desktop path
$desktopPath = [Environment]::GetFolderPath("Desktop")
$outputFolder = Join-Path $desktopPath "WindowsInventory"


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

    

        # Get Scheduled Tasks that are enabled or running
        $scheduledTasks = Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock {
            Get-ScheduledTask | Where-Object { $_.State -eq 'Ready' -or $_.State -eq 'Running' } | 
            Select-Object -Property TaskName, TaskPath, State | Format-List
        }

        # Get Autorun Entries 
        $autoruns = Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock {
            Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run", 
                             "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
                             "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce", 
                             "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" | 
            Select-Object -Property PSChildName, Path, Value  
        }

        # Get startup programs? Idk if this is different then the registry above?
        $startupInfo = Invoke-Command -ComputerName $computer.Name -Credential $credentials -ScriptBlock{
         Get-CimInstance Win32_StartupCommand | Select-Object Name, command, Location, User | Format-List
        }

        # Export Scheduled Tasks to txt
        Out-File -InputObject $scheduledTasks -FilePath (Join-Path $computerFolder "ScheduledTasks.txt") 


        # Export Autorun Entries to txt
        Out-File -InputObject $autoruns -FilePath (Join-Path $computerFolder "AutorunEntries.txt") 


        # Statups info to txt
        Out-File -InputObject $startupInfo -FilePath (Join-Path $computerFolder "StatupPrograms.txt") 
    }
}
