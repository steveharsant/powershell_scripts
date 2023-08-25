param (
  [string]$PathToWatch,
  [string]$ScriptBlockString
)

# Convert the script block string to a script block object
$ScriptBlock = [ScriptBlock]::Create($ScriptBlockString)

function Watch-Folder {
  param (
    [string]$Path,
    [scriptblock]$Action
  )

  $watcher = New-Object System.IO.FileSystemWatcher
  $watcher.Path = $Path
  $watcher.IncludeSubdirectories = $true

  $watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::DirectoryName

  $onChange = Register-ObjectEvent -InputObject $watcher -EventName Changed -Action {
    $event = $Event.SourceEventArgs
    Write-Host "CHANGED: $($event.FullPath)"

    # Stop the running script block, if it's not already stopped
    if ($global:RunningScript -ne $null -and $global:RunningScript.Runspace.RunspaceStateInfo.State -eq 'Running') {
      $global:RunningScript.Stop()
      Write-Host 'Script block stopped.'
    }

    # Start the script block
    $global:RunningScript = Start-Job -ScriptBlock $Action
  }

  $watcher.EnableRaisingEvents = $true

  do {
    Start-Sleep 1
  } while ($true)
}

# Call the function with the provided script block and the specified directory to watch
Watch-Folder -Path $PathToWatch -Action $ScriptBlock
