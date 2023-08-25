param (
  [string]$sourceFolder,
  [string]$handbrakeBinary = 'handbrake.exe'
)

$videoFiles = Get-ChildItem -Path $sourceFolder -File -Include *.mp4, *.mkv, *.avi, *.mov, *.wmv -Recurse

foreach ($videoFile in $videoFiles) {

  $videoDirectory = [System.IO.Path]::GetDirectoryName($videoFile.FullName)
  $baseName = [System.IO.Path]::GetFileNameWithoutExtension($videoFile.Name)
  $outputFile = Join-Path -Path $videoDirectory -ChildPath "$baseName.mkv"
  $handbrakeArgs = '--align-av --auto-anamorphic --maxWidth 3840 --encoder x265_10bit --rate 30 --pfr --quality 22 --encoder-preset fast --encoder-profile auto --encoder-level auto --aencoder av_aac --ab 160 --arate auto --mixdown stereo'

  Write-Output "Start video conversion for: $($videoFile.Name)"
  Write-Output "  File Directory: $videoDirectory"
  Write-Output "  Input File: $($videoFile.FullName)"
  Write-Output "  Output File: $outputFile"
  Write-Output "  Calling Handbrake with:`n`n"
  Write-Output "  $handbrakeBinary -i $($videoFile.FullName) -o $outputFile $handbrakeArgs `n`n"

  Start-Process -FilePath "$handbrakeBinary" `
    -ArgumentList "-i '$($videoFile.FullName)' -o '$outputFile' $handbrakeArgs" `
    -NoNewWindow -Wait

  if (Test-Path $outputFile) {
    Remove-Item -Path $videoFile.FullName -Confirm:$false -Force
    Write-Host "Conversion complete for $($videoFile.FullName). The original file has been replaced."
  } else {
    Write-Host "Conversion failed for $($videoFile.FullName). The output file does not exist."
  }
}

Write-Host "All video files in $sourceFolder and its subfolders have been processed."
