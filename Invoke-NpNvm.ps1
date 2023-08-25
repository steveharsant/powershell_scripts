[CmdletBinding()]
param (
  [Parameter()][string] $install,
  [Parameter()][string] $uninstall,
  [Parameter()][string] $use,

  [Parameter()][switch] $downloadNvm,
  [Parameter()][switch] $installNpNvm,
  [Parameter()][switch] $version,
  [Parameter()][switch] $help
)

$npnvmVersion = '0.1.0'
$helpMessage = "
No Privilege Node Version Manager (npnvm)

version: $npnvmVersion
Author: Steve Harsant (sharsant@milltechfx.com)

Downloads, installs and switches NodeJS versions without needing administrative rights.

Usage: Invoke-Npnvm [arguments]

Arguments:

  -install [version]      Specified the Node version to install
  -uninstall [version]    Specified the Node version to uninstall
  -use [version]          Specified the Node version to use

  -downloadNvm            Opens the download page for the nvm executable
  -installNpNvm           Installs the script to: $PROFILE
                          If no profile file exists, it will be created
  -version                Prints the npnvm version
  -help                   Prints this message

  Nvm For Windows can be found at: github.com/coreybutler/nvm-windows
"

Function Resolve-NvmExe {
  if ( Test-Path -Path "$PSScriptRoot\nvm.exe" ) { Return $true }
  else {
    Write-Host 'nvm.exe not found. Run' -ForegroundColor Red -NoNewline
    Write-Host ' npnvm -downloadNvm' -ForegroundColor Blue -NoNewline
    Write-Host ' to resolve' -ForegroundColor Red
  }
}

#*
#* npnvm commands
#*

# Open download page in default browser
if ( $downloadNvm.IsPresent ) {

  $nvmRepo = 'https://api.github.com/repos/coreybutler/nvm-windows/releases'
  $tag = ( Invoke-WebRequest $nvmRepo | ConvertFrom-Json )[0].tag_name
  Invoke-WebRequest "https://github.com/coreybutler/nvm-windows/releases/download/$tag/nvm-noinstall.zip" -OutFile "$PSScriptRoot\nvm-noinstall.zip"
  Expand-Archive -Path "$PSScriptRoot\nvm-noinstall.zip" -DestinationPath $PSScriptRoot -Force
  Remove-Item "$PSScriptRoot\nvm-noinstall.zip" -Recurse -Confirm:$false -Force
  exit 0
}

# Installs npnvm to $PROFILE
if ( $installNpNvm.IsPresent ) {

  try {
    $profilePath = Split-Path $PROFILE -Parent
    $installPath = "$profilePath\Scripts\npnvm"

    if (($PSScriptRoot ) -eq $installPath ) {
      Write-Host 'This version of npnvm is already installed' -ForegroundColor Yellow
      exit 1
    }

    if ( Test-Path -Path $installPath ) { Write-Output 'Found previous installation. Updating...' }
    else { Write-Output 'Installing npnvm' }

    # Copy script and nvm.exe into $PROFILE/scripts directory
    New-Item -ItemType Directory -Path $installPath -ErrorAction SilentlyContinue | Out-Null
    Copy-Item -Path $MyInvocation.MyCommand.Source -Destination "$installPath\$($MyInvocation.MyCommand.Name)" -Force
    if (Resolve-NvmExe) { Copy-Item -Path "$PSScriptRoot\nvm.exe" -Destination "$installPath\nvm.exe" -Force }

    # Install aliases to $PROFILE if they are missing
    $aliases = @('Invoke-NpNvm', 'npnvm', 'nvm')

    foreach ($alias in $aliases) {
      $setAlias = Get-Content -Path $PROFILE | Where-Object { $_ -match "New-Alias -Name $alias" }
      if ([string]::IsNullOrEmpty($setAlias)) {
        Add-Content -Path $PROFILE -Value "New-Alias -Name $alias -Value '$installPath\$($MyInvocation.MyCommand.Name)'"
        $setAlias = $null
      }
    }
  }

  catch {
    Write-Host 'Failed to install npnvm for the current user' -ForegroundColor Red
    exit 1
  }

  Write-Host 'Successfully install npnvm' -ForegroundColor Green
  Write-Output "`nnpnvm can be called the with the following commands:`n   Invoke-NvNpm`n   npnvm`n   nvm`n`n You may need to source your profile with: . `$PROFILE"

  exit 0
}

# Print version and exit
if ( $version.IsPresent ) {
  Write-Output "npnvm $npnvmVersion"
  if ( Resolve-NvmExe ) { Write-Output "nvm $(& $PSScriptRoot\nvm.exe version)" }
  exit 0
}

# Print help and exit
if ( $help.IsPresent -or ( $PSBoundParameters.Values.Count -eq 0 )) { Write-Output $helpMessage; exit 0 }

#*
#* nvm commands
#*

# Check if nvm.exe is found
if ( !(Resolve-NvmExe) ) { exit 1 }

if ( ![string]::IsNullOrEmpty($install) ) { & $PSScriptRoot\nvm.exe install $install }
if ( ![string]::IsNullOrEmpty($uninstall) ) { & $PSScriptRoot\nvm.exe uninstall $install }

#* nvm use - This is the main reason for this script to exist as it manages
#*           which version to use without administrator rights...

if ( ![string]::IsNullOrEmpty($use) ) {

  if ($use[0] -ne 'v') { $use = "v$use" }
  $nodePath = "$env:USERPROFILE\AppData\Roaming\nvm"

  if (!( Test-Path -Path "$nodePath\$use" )) {
    Write-Host "Node version $use is not installed. Install it with" -ForegroundColor Red -NoNewline
    Write-Host " npnvm install $use" -ForegroundColor Blue -NoNewline
    Write-Host ' and try again' -ForegroundColor Red
    exit 1
  }

  # Parse user PATH and update with specified Node version
  $pathKey = 'Registry::HKEY_CURRENT_USER\Environment'
  $path = ((Get-ItemProperty -Path $pathKey -Name PATH).path).Split(';')  | Where-Object { $_ -notmatch $nodePath.replace('\','\\')}
  $path = "$($path -join ';');$nodePath\$use"

  # Rename the node version if it is a 64-bit install
  if (Test-Path -Path "$nodePath\$use\node64.exe"){
    Move-Item -Path "$nodePath\$use\node64.exe" -Destination "$nodePath\$use\node.exe"
  }

  # Set registry with new user PATH variable
  try { Set-ItemProperty -Path $pathKey -Name PATH -Value $path }
  catch { Write-Host 'Failed to update PATH for the current user' -ForegroundColor Red; exit 1 }

  # Update the current shells PATH
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

}
