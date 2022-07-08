function New-VagrantBox {
  param (
    [Parameter(Mandatory = $true)][String][ValidateSet('debian', 'ubuntu', 'windows')] $box,
    [Parameter()][String]                                                              $name,
    [Parameter()][String]                                                              $path = "$env:USERPROFILE\VMs\Vagrant",
    [Parameter()][Switch]                                                              $force = $false
  )

  # Set the box name that matches Vagrant Hub (owner/box)
  switch ($box) {
    'debian' { $boxId = 'generic/debian11' }
    'ubuntu' { $boxId = 'generic/ubuntu2204' }
    'windows' { $boxId = 'gusztavvargadr/windows-server' }
  }

  # Generate a unique name for the VM if none set
  if ([string]::IsNullOrEmpty($name)) {
    $name = "$($boxId.Split('/')[1])-$(Get-Date -Format 'yyMMdd_HHmmss')"
  }

  # Check if the VM with the specified name already exists
  if ( (Test-Path -Path "$path/$name") -and ($force -eq $false) ) {
    Write-Output "VM '$name' already exists"
  }

  # If the VM exists but force is set, remove it before recreating
  elseif ( (Test-Path -Path "$path/$name") -and ($force -eq $true) ) {
    Write-Output "VM '$name' already exists. Destroying..."
    Push-Location -Path "$path/$name"
    Invoke-Expression -Command 'vagrant destroy -f'
    Pop-Location

    try { Remove-Item -Path "$path/$name" -Recurse -Confirm:$false -Force }
    catch { throw "Failed to delete $path/$name" }

  }

  # Create the VM path and run 'vagrant init'
  try {
    New-Item -ItemType Directory -Path "$path/$name" -ErrorAction SilentlyContinue | Out-Null
    Push-Location "$path/$name"
    Invoke-Expression -Command "vagrant init $boxId"
  } catch { throw 'Failed to initalise box' }

  # Get Vagrantfile content and trim 'end' from the last line, add the vm name and write it back to the file
  try {
    $vagrantfileContent = Get-Content -Path './Vagrantfile'
    $vagrantfileContent = $vagrantfileContent[0..$($vagrantfileContent.count - 2)]
    $vagrantfileContent += "vmname = `"$name`"`nend"
    Set-Content -Path './Vagrantfile' -Value $vagrantfileContent -Force
  } catch { throw 'Failed to set VM name' }

  # Run 'vagrant up'
  Invoke-Expression -Command 'vagrant up'

  Pop-Location
}

New-Alias nvb New-VagrantBox
Export-ModuleMember -Alias * -Function *
