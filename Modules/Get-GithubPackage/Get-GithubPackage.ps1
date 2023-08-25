curl -H "Authorization: token ab499f3b..." \
-L https://api.github.com/repos/godzilla/my_priv_repo/tarball > wut.tar.gz

function Get-GithubPackage {
  param (
    [Parameter(Mandatory = $true, Position = 1)][String] $box,
    [Parameter(Mandatory = $false, Position = 2)][String] $path = "$env:USERPROFILE\vagrant_boxes"
  )

  curl `
    -H "Authorization: token ab499f3b..." `
    -L https://api.github.com/repos/godzilla/my_priv_repo/tarball > `
    wut.tar.gz
}

New-Alias gdl Get-GithubPackage
export-modulemember -alias * -function *
