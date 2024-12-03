# Import the Active Directory module (for systems with RSAT tools or on Domain Controllers)
Import-Module ActiveDirectory

# Define user details for the new domain admin accounts
$AdminAccounts = @(
    @{Username = "VRat"; Name = "Vincent Rat"; Password = "qwerty12345!@#$%"},
    @{Username = "Dlem"; Name = "Drew Lem"; Password = "qwerty12345!@#$%"},
    @{Username = "Jbar"; Name = "Jacob Bar"; Password = "qwerty12345!@#$%"}
)

# Define the accounts that should remain as Domain Admins
$AllowedAdmins = $AdminAccounts.Username + @("black_team")

# Loop through each account and create it in AD
foreach ($account in $AdminAccounts) {
    # Convert password to secure string
    $SecurePassword = ConvertTo-SecureString $account.Password -AsPlainText -Force

    # Create the user account with secure password
    New-ADUser -Name $account.Name `
               -SamAccountName $account.Username `
               -UserPrincipalName "$($account.Username)@$((Get-ADDomain).dnsroot)" `
               -AccountPassword $SecurePassword `
               -ChangePasswordAtLogon $true `
               -Enabled $true `
               -PasswordNeverExpires $false `
               -Path (Get-ADDomain).DistinguishedName

    Write-Host "User '$($account.Username)' created successfully."

    # Add the user to the Domain Admins group
    Add-ADGroupMember -Identity "Domain Admins" -Members $account.Username

    Write-Host "User '$($account.Username)' added to the Domain Admins group."
}

# Remove any other accounts from the Domain Admins group
$CurrentDomainAdmins = Get-ADGroupMember -Identity "Domain Admins" | Where-Object { $_.objectClass -eq 'user' }

foreach ($admin in $CurrentDomainAdmins) {
    if ($admin.SamAccountName -notin $AllowedAdmins) {
        Remove-ADGroupMember -Identity "Domain Admins" -Members $admin.SamAccountName -Confirm:$false
        Write-Host "User '$($admin.SamAccountName)' removed from Domain Admins group."
    }
}
