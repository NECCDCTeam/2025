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
                   -UserPrincipalName "$($account.Username)@SECURENETWORK.com" # change hard coded
                   -AccountPassword $SecurePassword `
                   -Enabled $true `
                   -PasswordNeverExpires $true `
                   -Path "CN=Users,DC=SECURENETWORK.com,DC=DC-01" # change hard coded
        
        # Add the user to the Domain Admins group
        Add-ADGroupMember -Identity "Domain Admins" -Members $account.Username

        Write-Output "Domain Admin account '$($account.Username)' created and added to Domain Admins group."

    } catch {
        Write-Output "An error occurred while creating the account '$($account.Username)': $_"
    }
}
# fix issue with enabaling accoutns and adding them to the domain admins group 
# fix issue with -AccountPassword $SecurePassword  flag