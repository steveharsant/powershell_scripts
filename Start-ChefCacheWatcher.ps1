New-Item -Type Directory -Path "C:\Temp\chef_cache" -ErrorAction SilentlyContinue

$source = "C:\Users\vagrant\AppData\Local\Temp\"
$destination = "C:\Temp\chef_cache\"
$filter = "*.ps1"
$watcher = New-Object IO.FileSystemWatcher $source, $filter -Property @{
    IncludeSubdirectories = $false
    NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'
}
$onCreated = Register-ObjectEvent $Watcher -EventName Created -SourceIdentifier FileCreated -Action {
   $path = $Event.SourceEventArgs.FullPath
   $name = $Event.SourceEventArgs.Name
   $changeType = $Event.SourceEventArgs.ChangeType
   $timeStamp = $Event.TimeGenerated
   Write-Host "Copying file $name that was $changeType at $timeStamp" -ForegroundColor Green
   Copy-Item $path -Destination $destination -Force
}
