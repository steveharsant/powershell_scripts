# https://www.youtube.com/playlist?list=PL5IO44e-w1nSEczuQfO8yoITxoNMPxWaD


# $regex = '^.*href="\/watch\?v=.*$|^.*minutes.*$|.*title=".+".*$'

# $file = Get-Content -Path "C:\Users\Steve\test\artifact.html"

# $list = @()
# $n = 0

# foreach ($line in $file) {
#   $n++
#   Write-host "Entering loop number: $n" -ForegroundColor Blue

#   if ($line -match '^.*href="\/watch\?v=.*$|^.*minutes.*$|.*title=".+".*$') {
#     Write-Host "Hit" -ForegroundColor Green
#     $list += $line
#   }
# }

# $list | Out-file "C:\Users\Steve\test\output.txt"


# $file = Get-Content -Path "C:\Users\Steve\test\output.txt"

# $list = @()
# $n = 0

# foreach ($line in $file) {
#   $n++

#   Write-host "Entering loop number: $n" -ForegroundColor Blue


#   if ($line -match '^\s+href="\/watch\?v=(.*)&amp;list.*$' ) {
#     $videoUrl = $matches[1]
#     Write-host "Matched url" -ForegroundColor Yellow
#   }
#   if ($line -match '^\s+aria-label="([0-9].*)">$' ) {
#     $time = $matches[1]
#     Write-host "Matched time" -ForegroundColor Yellow
#   }
#   if ($line -match '^\s+aria-label="([a-zA-Z].*)\sby.*$' ) {
#     $title = $matches[1]
#     Write-host "Matched title" -ForegroundColor Yellow
#   }

#   if (($videoUrl -ne $null) -and ($time -ne $null) -and ($title -ne $null)) {
#     Write-host "Added new entry to list" -ForegroundColor Green
#     $list += "$title|$time|$videoUrl"

#     $title = $null
#     $time = $null
#     $title = $null
#   }
# }

# $list | Out-file "C:\Users\Steve\test\filtered_output.txt"


# $file = Get-Content -Path "C:\Users\Steve\test\filtered_output.txt"

# $list = @()
# $n = 0

# $file = $file | ? { $_ -notmatch 'YIN' }
# $file = $file | ? { $_ -notmatch 'restorative' }
# $file = $file | ? { $_ -notmatch 'restore' }
# $file = $file | ? { $_ -notmatch 'dharma' }
# $file = $file | ? { $_ -notmatch 'dance' }
# $file = $file | ? { $_ -notmatch 'interview' }


# $file | Out-file "C:\Users\Steve\test\filtered_types_output.txt"






# $file = Get-Content -Path "C:\Users\Steve\test\filtered_types_output.txt"
# $list = @()

# foreach ($line in $file) {
#   if ($line -notmatch 'hour') {
#     $n++
#   }
# }

# $n


$file = Get-Content -Path "C:\Users\Steve\test\filtered_types_output.txt"

$list = @()
$n = 0

foreach ($line in $file) {
  $n++

  Write-host "Entering loop number: $n" -ForegroundColor Blue


  if ($line -match '([0-9]+)\shour' ) {
    $hours = [int]$matches[1] * 60

  }
  if ($line -match '([0-9]+)\sminutes' ) {
    $mins = [int]$matches
  }


  if (($videoUrl -ne $null) -and ($time -ne $null) -and ($title -ne $null)) {
    Write-host $hours+$mins

    $hours = $null
    $mins = $null

  }
}

# $list | Out-file "C:\Users\Steve\test\filtered_output.txt"
