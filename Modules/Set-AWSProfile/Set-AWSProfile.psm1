# As AWS RDK has a bug where it can ONLY use the default profile as of version 0.7.12
# this module serves as a workaround so we can swap profiles whilst keeping them as 'default'
# in the eyes of RDK

function Set-AWSProfile {
  param (
    [Parameter()][switch] $default,
    [Parameter()][switch] $mgmt,
    [Parameter()][switch] $swift,
    [Parameter()][switch] $prod
  )

  $credentialsFile = "$env:USERPROFILE/.aws/credentials"

  # Exit function if too many arguments are given
  if ($PSBoundParameters.Count -gt 1) {
    Write-Host 'Too many arguments given. Only 1 argument is accepted' -ForegroundColor Yellow
    exit 1
  }

  # Delete credentials file if it exists
  if (!(Test-Path -Path $credentialsFile)) {
    Remove-Item $credentialsFile -Confirm:$false -Force
  }

#
# Determine which profile to use
#

  # Default / Non-Prod aaccount
  if (($default.IsPresent) -or ($PSBoundParameters.Count -eq 0)) {
    $awsProfile = "default"
  }
  # Management account
  elseif ($mgmt.IsPresent) {
    $awsProfile = "mgmt"
  }
  # Swift account
  elseif ($mgmt.IsPresent) {
    $awsProfile = "swift"
  }
  # Production account
  elseif ($prod.IsPresent) {
    Write-Host "Are you sure you want to set your profile to the PRODUCTION account? " -ForegroundColor Red -NoNewline
    $confirm = Read-Host

    if ($confirm -match 'y') {
      $awsProfile = "prod"
    }
    else { return }
  }

  # Copy contents of desired credentials file into the main credentials file
  $newProfile = "$env:USERPROFILE/.aws/credentials_$awsProfile"

  if (!(Test-Path -Path $newProfile)) {
    Write-Host "Credentials file for the $awsProfile profile was not found" -ForegroundColor Yellow
    return
  }

  Get-Content -Path $newProfile | Out-File $credentialsFile -Encoding utf8

  Write-Host "AWS Access Key and Secret Key set to the $awsProfile account" -ForegroundColor Cyan

}




# function Set-AWSProfile {
#   param (
#     [Parameter()][switch] $default,
#     [Parameter()][switch] $mgmt,
#     [Parameter()][switch] $prod
#   )

#   $credentialsFile = "$env:USERPROFILE/.aws/credentials"

#   if ($PSBoundParameters.Count -gt 1) {
#     Write-Host 'Too many arguments given. Only 1 argument is accepted' -ForegroundColor Yellow
#     Return
#   }

#   if (!(Test-Path -Path $credentialsFile)) {
#     Write-Host "Cannot find AWS credentials file at: $credentialsFile"
#     Return
#   }

#   $credentials = Get-Content $credentialsFile

#   if (($default.IsPresent) -or ($PSBoundParameters.Count -eq 0)) {
#     $awsProfile = "default"
#   }
#   elseif ($mgmt.IsPresent) {
#     $awsProfile = "mgmt"
#   }
#   elseif ($prod.IsPresent) {
#     Write-Host "Are you sure you want to set your profile to the PRODUCTION account? " -ForegroundColor Red -NoNewline
#     $confirm = Read-Host

#     if ($confirm -match 'y') {
#       $awsProfile = "prod"
#     }
#     else { return }
#   }


#   # Get position of profile name
#   for ($i = 0; $i -lt $credentials.Count; $i++) {
#     if ($credentials[$i] -match $awsProfile) {
#       $position = $i
#       break
#     }
#   }

#   $env:AWS_ACCESS_KEY_ID = $credentials[$position + 1].split('=')[1]
#   $env:AWS_SECRET_ACCESS_KEY = $credentials[$position + 2].split('=')[1]
#   $env:AWS_PROFILE = $awsProfile

#   Write-Host "AWS Access Key and Secret Key set to the $awsProfile account with access key: $env:AWS_ACCESS_KEY_ID" -ForegroundColor Cyan
# }

export-modulemember -alias * -function *
