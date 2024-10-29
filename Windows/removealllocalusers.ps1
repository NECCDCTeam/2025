# Get a list of all local users
$UsersToDisable = Get-LocalUser

# Loop through each user and disable the account
foreach ($Account in $UsersToDisable) {
    try {
        # Check if the account is enabled
        if ($Account.Enabled) {
            # Disable the account
            Disable-LocalUser -Name $Account.Name
            Write-Output "User account '$($Account.Name)' has been disabled."
        } else {
            Write-Output "User account '$($Account.Name)' is already disabled."
        }
    } catch {
        Write-Output "An error occurred while processing user account '$($Account.Name)'."
    }
}
