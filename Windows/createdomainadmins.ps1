# Import the Active Directory module (for systems with RSAT tools or on Domain Controllers)
Import-Module ActiveDirectory

# Define user details for the new domain admin accounts
$AdminAccounts = @(
    @{Username = "VRatcliffe"; Name = "Vincent Ratcliffe"; Password = "qwerty12345!@#$%"},
    @{Username = "Dlemansky"; Name = "Drew Lemansky"; Password = "qwerty12345!@#$%"},
    @{Username = "Jbarber"; Name = "Jacob Barber"; Password = "qwerty12345!@#$%"}
)

# Loop through each account and create it in AD
foreach ($account in $AdminAccounts) {
    try {
        # Convert password to secure string
        $SecurePassword = ConvertTo-SecureString $account.Password -AsPlainText -Force
        
        # Create the user account
        New-ADUser -Name $account.Name `
                   -SamAccountName $account.Username `
                   -UserPrincipalName "$($account.Username)@yourdomain.com" `
                   -AccountPassword $SecurePassword `
                   -Enabled $true `
                   -PasswordNeverExpires $true `
                   -Path "CN=Users,DC=yourdomain,DC=com" # Change to your target OU if needed
        
        # Add the user to the Domain Admins group
        Add-ADGroupMember -Identity "Domain Admins" -Members $account.Username

        Write-Output "Domain Admin account '$($account.Username)' created and added to Domain Admins group."

    } catch {
        Write-Output "An error occurred while creating the account '$($account.Username)': $_"
    }
}
