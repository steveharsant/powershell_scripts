# Super simple script to start apps from a folder with admin rights.
# This was created to have Windows Task Scheduler run this script on
# startup and load a group of apps that need admin rights.

param ($startPath = '~/admin_startup_apps')

$apps = Get-ChildItem -Path $startPath

foreach ($app in $apps) {
  Start-Process "$startPath\$($app.name)"
}
