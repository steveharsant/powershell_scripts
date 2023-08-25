param (
  [string]$folderPath
)

function Get-RelativePath {
  param (
    [string]$basePath,
    [string]$fullPath
  )
  $relativePath = (Get-Item $fullPath).FullName.Replace((Get-Item $basePath).FullName, '')
  if ($relativePath.StartsWith('\')) {
    $relativePath = $relativePath.Substring(1)
  }
  return $relativePath
}

$currentFolderPath = Get-Item -Path $folderPath

function Write-FileAndContents {
  param (
    [string]$filePath
  )
  $relativePath = Get-RelativePath -basePath $currentFolderPath.FullName -fullPath $filePath
  Write-Host "File: $relativePath"
  Write-Host 'Contents:'
  Get-Content $filePath | ForEach-Object {
    Write-Host $_
  }
  Write-Host
}

# Get all the files with specified extensions in the current folder and its subfolders
$allowedExtensions = @('.go', '.css', '.js', '.html', '.py')
$files = Get-ChildItem -Path $folderPath -File -Recurse | Where-Object { $allowedExtensions -contains $_.Extension } | Where-Object { 'OLD' -notcontains $_.FullName }

foreach ($file in $files) {
  Write-FileAndContents -filePath $file.FullName
}
