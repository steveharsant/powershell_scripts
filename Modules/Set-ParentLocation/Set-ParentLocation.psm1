function Set-ParentLocation {
    param (
      [Parameter(Mandatory = $false, Position = 1)]
      [String]
      $path
  )

  $fullPath = (Get-Location).path

  if($path -eq '')
  {
      $fullPath -match "(.*\\)" | Out-Null
      Set-Location $Matches[0]
  }
  else
  {
      $regexMatcher = "(.*$path[^\\]*)"
      $fullPath -match $regexMatcher | Out-Null
      if($fullPath -eq $Matches[0])
      {
          Write-Host "Unable to guess the path. Be more specific" -ForegroundColor Yellow
      }
      else {
        Set-Location $Matches[0]
      }
  }
   }

New-Alias bd Set-ParentLocation
export-modulemember -alias * -function *
