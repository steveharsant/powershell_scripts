function Get-DockerIpAddress {
  $containerInfo = docker container ls -q
  foreach ($id in $containerInfo) {
    Write-Host "$id " -NoNewline
    docker.exe inspect --format '{{ .NetworkSettings.IPAddress }}' $id
  }
}
