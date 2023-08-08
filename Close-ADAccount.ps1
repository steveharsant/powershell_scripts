[CmdletBinding()]
param (
  [Parameter][string] $username
)

function Write-FailureLog {
  param ($message)
  Write-Host "$message. Exiting in 10 seconds" -ForegroundColor Red
  Start-Sleep 10
  exit 1
}

try {
  Import-Module ActiveDirectory
} catch {
  Write-FailureLog 'Failed to import Active Directory PowerShell module'
}

if ([string]::IsNullOrEmpty($username)) {
  Clear-Host
  $username = Read-Host 'Enter the Active Directory username: '
}

$user = Get-ADUser -Identity $username
if ([string]::IsNullOrEmpty($user)) {
  Write-FailureLog -message "Failed to find user object for $username"
}

try {
  # Disable the user account
  Write-Host 'Disabling user account' -ForegroundColor blue
  Disable-ADAccount -Identity $username
} catch {
  Write-FailureLog -message 'Failed to disable account'
}

try {
  Write-Host 'Invalidating user password with randomly generated one' -ForegroundColor blue
  $randomPassword = -join ((65..90) + (97..122) + (48..57) + (33..47) | Get-Random -Count 20 | ForEach-Object { [char]$_ })
  Set-ADAccountPassword -Identity $username -NewPassword (ConvertTo-SecureString -AsPlainText $randomPassword -Force)
} catch {
  Write-FailureLog -message 'Failed to invalidate account password'
}

try {
  Write-Host 'Adding leaving date to user account description' -ForegroundColor blue
  $today = Get-Date -Format 'dd/MM/yyyy'
  $description = "Leaver - $today"
  Set-ADUser -Identity $username -Description $description
} catch {
  Write-FailureLog -message 'Failed to add leaving date to description'
}

try {
  Write-Host "Moving user account to 'Millennium Global Leavers' group" -ForegroundColor blue
  $ouPath = 'OU=Millennium Global Leavers,DC=mgi,DC=local'
  Move-ADObject -Identity $user.DistinguishedName -TargetPath $ouPath
} catch {
  Write-FailureLog -message "Failed to move account to 'Millennium Global Leavers' group"
}

Write-Host "Account closure for $username completed successfully. Exiting in 10 seconds"
Start-Sleep 10
exit 0
