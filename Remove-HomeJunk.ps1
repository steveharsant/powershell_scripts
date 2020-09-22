# Quick script to delete junk directories from my home directory
$directoryNames = '3D Objects', 'Contacts', 'Favorites', 'Links', 'Music', 'Saved Games', 'Searches', 'Videos'
foreach ($directory in $directoryNames) {
    Remove-Item -Path "$env:USERPROFILE\$directory" -ErrorAction SilentlyContinue | Out-Null
}
