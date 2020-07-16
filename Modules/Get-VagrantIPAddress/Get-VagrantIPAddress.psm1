function Get-VagrantIPAddress {
  (Get-VM | Where-Object {$_.state -eq 'Running'} | Get-VMNetworkAdapter) | Where-Object {
    $_.ipAddresses -like "*172.*" -or $_.ipAddresses -like "*192.*"
  } | Select-Object VMName, IpAddresses
}
