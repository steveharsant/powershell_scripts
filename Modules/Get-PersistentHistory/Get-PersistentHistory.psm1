# Add the following lines (uncommented) to your Powershell profile to remap history alias
# Remove-Item Alias:History -Force
# New-Alias history Get-PersistentHistory

function Get-PersistentHistory
{
  param (
    $head,
    $tail
  )

  if (!([string]::IsNullOrEmpty($head)) -and !([string]::IsNullOrEmpty($tail)))
  {
    Write-Output 'Conflicting arguements passed. Pass either head or tail, no both.'
  }
  else
  {
    $historyFilePath = "C:\Users\$env:UserName\appdata\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

    if (!([string]::IsNullOrEmpty($head)))
    {
      Get-Content $historyFilePath | Select-Object -First $head
    }
    elseif (!([string]::IsNullOrEmpty($tail)))
    {
      Get-Content $historyFilePath | Select-Object -Last $tail
    }
    else
    {
      Get-Content $historyFilePath
    }
  }
}

Export-ModuleMember -alias * -function *
