# Powershell version of watch for linux
function Watch-Command {
Param(
  [Parameter(Mandatory=$true)]
  [String]
  $command
)

    while ($true) {Clear-Host; & $command; Start-Sleep 1; Clear-Host}
}

New-Alias watch Watch-Command
export-modulemember -alias * -function *
