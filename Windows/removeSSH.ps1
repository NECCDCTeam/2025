#Remove
Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Remove-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Remove-Item -Path "C:\Windows\System32\ssh.exe" -Force
Remove-Item -Path "C:\Windows\System32\sshd.exe" -Force
Remove-Item -Path "C:\ProgramData\ssh" -Recurse -Force



#Check
Get-Service | Where-Object Name -like '*ssh*'
Get-Process | Where-Object Name -like '*ssh*'
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

