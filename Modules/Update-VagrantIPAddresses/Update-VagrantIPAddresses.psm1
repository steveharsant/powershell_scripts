function Update-VagrantIPAddresses {
  Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $pathToCookbooks,

    [Parameter(Mandatory=$false)]
    [switch]
    $dryRun
)

  try {
    # Collect information for cookbooks and Hyper-V VMs
    if(Test-Path $pathToCookbooks) {
      $cookbookList = Get-ChildItem $pathToCookbooks
    }
    else {
      Write-Host "ERROR: The root path for Chef Cookbooks does not exist. Ensure the path is correct and try again." -ForegroundColor Red
    }

    # Get runnings VMs
    $aliveVMs = (Get-VM | Select-Object -ExpandProperty NetworkAdapters | Select-Object VMName, IPAddresses, Status | Where-Object {$_.Status -eq 'OK'})
    if ([string]::IsNullOrEmpty($aliveVMs)) {
      Write-Host "WARN: There are no running Hyper-V virtual machines. Power on the desired virtual machine, and try again" -ForegroundColor Yellow
    }
  }
  catch {
    Write-Host "ERROR: Failed to collect information for cookbooks or Hyper-V virtual machines." -ForegroundColor Red
  }

  # Allow script to continue even if try catch statements throw errors
  $ErrorActionPreference = "Continue"

  foreach ($vm in $aliveVMs) {
    # Regex match each VM name
    $vm.VMName -match '^(kitchen-(.*)(-windows.*vag)).*' | Out-Null
    $currentCookbook = $Matches[2]
    $vagrantBox = $Matches[3]
    $updatedIP = $vm.IPAddresses[0]

    # Loop through cookbooks for matching cookbook name to VM name
    foreach ($cookbook in $cookbookList) {
      if ($currentCookbook -match $cookbook) {
        $ymlFilePath = "$pathToCookbooks\$cookbook\.kitchen\" + ($currentCookbook.replace("$cookbook-", '') + $vagrantBox + '.yml')
        if (!(Test-Path $ymlFilePath)) {
          Write-Host "ERROR: Failed to discern the correct kitchen .yml file for $vm.VMName." -ForegroundColor Red
        }
        else {
          try {
            $ymlFileContent = Get-Content $ymlFilePath
          }
          catch {
            Write-Host "ERROR: Failed to retreive the contents of $ymlFilePath." -ForegroundColor Red
          }

          # Regex match IP address in .yml file
          $ymlFileNameIP = ($ymlFileContent -match "^hostname:\s\d+\.\d+\.\d+\.\d+$").replace("hostname: ", '')
          if ([string]::IsNullOrEmpty($ymlFileNameIP)) {
            Write-Host "ERROR: Failed to match the IP address in $ymlFilePath." -ForegroundColor Red
          }

          if ($ymlFileNameIP -eq $updatedIP) {
            Write-Host "INFO: Nothing to update for $currentCookbook$VagrantBox" -ForegroundColor Blue
          }
          else {
            $ymlFileContent = $ymlFileContent.replace($ymlFileNameIP, $updatedIP)

            # Update IP or output changes if -dryRun is set
            try {
              if($dryRun.IsPresent) {
                Write-Host "INFO: [ $updatedIP ] will replace with [ $ymlFileNameIP ] in $ymlFilePath" -ForegroundColor Blue
              }
              else {
                Set-Content -Value $ymlFileContent -Path $ymlFilePath
                Write-Host "SUCCESS: [ $ymlFileNameIP ] was replaced with [ $updatedIP ] in $ymlFilePath" -ForegroundColor Green
              }
            }
            catch {
              Write-Host "ERROR: Failed to update the IP address in $ymlFilePath." -ForegroundColor Red
            }
          }
        }
      }
    }
  }
}

New-Alias upv Update-VagrantIPAddresses
export-modulemember -alias * -function *
