function New-VagrantBox {
  param (
    [Parameter(Mandatory = $true, Position = 1)]
    [String]
    $box,

    [Parameter(Mandatory = $false, Position = 2)]
    [String]
    $path = "$env:USERPROFILE\vagrant_boxes"
  )

  # Check syntax of box name
  if ($box -notmatch '/') {
    Write-Output 'Required syntax: New-VagrantBox -box ownerName/boxName'
    exit 1
  }

  # Create path for new box
  $newBoxPath = "$path\$($box.Split('/')[1])"
  New-Item -ItemType Directory -Path $newBoxPath -ErrorAction SilentlyContinue | Out-Null

  # Get the current location and switch to the new box path
  $currentPath = Get-Location
  Set-Location $newBoxPath

  # Create the box
  vagrant init $box
  vagrant up

  # Return to the original location
  Set-Location $currentPath
}

New-Alias nvb New-VagrantBox
export-modulemember -alias * -function *
