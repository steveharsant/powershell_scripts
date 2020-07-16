function tf {
  # Set to the command for each version, or path to exe
  $terraformLocalVersion = 'terraform'
  $terraformCloudVersion = 'terraform12.20'

  $versionRegex = 'v[0-9]*\.[0-9]*\.[0-9]*'
  if($args -match 'state' -or $args -match 'import')
  {
    Write-Host $($(& $terraformCloudVersion -v) -match $versionRegex) -ForegroundColor Yellow
    & $terraformCloudVersion $args
  }
  else {
    Write-Host $($(& $terraformLocalVersion -v) -match $versionRegex) -ForegroundColor Yellow
    & $terraformLocalVersion $args
  }
}

export-modulemember -alias * -function *
