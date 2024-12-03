# Import the Active Directory module (for systems with RSAT tools or on Domain Controllers)
Import-Module ActiveDirectory

# Define user details for the new domain admin accounts
$AdminAccounts = @(
    @{Username = "VRat"; Name = "Vincent Rat"; Password = "qwerty12345!@#$%"},
    @{Username = "Dlem"; Name = "Drew Lem"; Password = "qwerty12345!@#$%"},
    @{Username = "Jbar"; Name = "Jacob Bar"; Password = "qwerty12345!@#$%"}
)

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
