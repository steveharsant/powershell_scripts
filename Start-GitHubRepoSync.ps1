# Syncs repositories from GitHub to a local directory.
# Requires PowershellForGitHub and git to be installed and setup.
param (
  $excludeFilter,
  $includeFilter,
  $localPath
)

try {
  Import-Module PowershellForGitHub
}
catch {
  Write-Error 'Failed to import PowershellForGitHub module'
  exit 1
}

# Get repos and apply include/exclude filter
try {
  $repos = Get-GitHubRepository |  Where-Object { $_.full_name -like "*$includeFilter*" }
  if ($null -ne $excludeFilter) { $repos = $repos | Where-Object { $_.full_name -notlike "*$excludeFilter*" } }
}
catch {
  Write-Error 'Failed to get list of repositories on remote'
  exit 1
}


foreach ($repo in $repos) {

  $repoName = $repo.full_name.Split('/')[1]

  if ( Test-Path -Path "$localPath\$repoName" ) {
    Set-Location -Path "$localPath\$repoName"
    Write-Host "Pulling https://github.com/$($repo.full_name).git"
    git pull origin master | Out-Null

    $command = 'Pull'
  }
  else {
    Set-Location -Path $localPath
    Write-Host "Cloning https://github.com/$($repo.full_name).git" -foregroundColor Yellow
    git clone https://github.com/$($repo.full_name).git | Out-Null

    $command = 'Clone'
  }

  if ($?) {
    Write-Host "$command successful: $repoName " -foregroundColor Green
  }
  else {
    Write-Host "$command failed: $repoName" -foregroundColor Red
  }
}
