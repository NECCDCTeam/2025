# Get desktop path
$desktopPath = [Environment]::GetFolderPath("Desktop")
$outputFolder = Join-Path $desktopPath "WindowsInventory"

# Create output folder on the desktop
if (!(Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder
}

# Create folder specific to the local computer
$computerName = $env:COMPUTERNAME
$computerFolder = Join-Path $outputFolder $computerName
if (!(Test-Path $computerFolder)) {
    New-Item -ItemType Directory -Path $computerFolder
}

# Get Scheduled Tasks that are enabled or running
$scheduledTasks = Get-ScheduledTask | Where-Object { $_.State -eq 'Ready' -or $_.State -eq 'Running' } | 
    Select-Object -Property TaskName, TaskPath, State | Format-List

# Get Autorun Entries
$autoruns = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run", 
                             "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
                             "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce", 
                             "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" | 
    Select-Object -Property PSChildName, Path, Value

# Get startup programs
$startupInfo = Get-CimInstance Win32_StartupCommand | 
    Select-Object Name, Command, Location, User | Format-List

# Export Scheduled Tasks to txt
Out-File -InputObject $scheduledTasks -FilePath (Join-Path $computerFolder "ScheduledTasks.txt")

# Export Autorun Entries to txt
Out-File -InputObject $autoruns -FilePath (Join-Path $computerFolder "AutorunEntries.txt")

# Export Startup Programs to txt
Out-File -InputObject $startupInfo -FilePath (Join-Path $computerFolder "StartupPrograms.txt")
