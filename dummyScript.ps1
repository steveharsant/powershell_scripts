# A dummy script to be compiled into an .exe with PS2EXE
# https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-e7cb69d5

$myLocation = Get-Location
Write-Output "I was last run at: $(Get-Date)" | Out-File -FilePath "$myLocation\output.txt" -Append -Force
