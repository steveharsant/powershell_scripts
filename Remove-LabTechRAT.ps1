$services = Get-Service | Where-Object { $_.DisplayName -match 'Tribeca' }

foreach ($service in $services) {
  Stop-Service -Name $service.Name
  Set-Service -Name $service.Name -StartupType Disabled
}

$exes = @( 'LSR', 'LTSVC', 'LTSvcMon', 'LTTray', 'PS')

foreach ($exe in $exes) {

  Stop-Process -ProcessName $exe -Force -ErrorAction SilentlyContinue

  $file = "C:\Windows\LTSvc\$exe.exe"

  if ( (Test-Path -Path $file) -and ((Get-Item $file).length -ne 0) ) {
    Remove-Item -Path $file -Confirm:$false -Force
    New-Item -ItemType File -Path $file | Out-Null
  }
}

Write-Output 'Complete'
