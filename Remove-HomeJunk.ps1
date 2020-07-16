# Quick script to delete junk directories from my home directory

$directoryNames = '3D Objects', 'Contacts', 'Favorites', 'Links', 'Music', 'Saved Games', 'Searches', 'Videos'

foreach ($directory in $directoryNames) {
    if(Test-Path -Path "C:\Users\Steveh\$directory")
    {
        Remove-Item -Force -Path "C:\Users\Steveh\$directory" -ErrorAction SilentlyContinue | Out-Null

        if(Test-Path -Path "C:\Users\Steveh\$directory")
        {
            Write-Host "Failed to delete $directory" -ForegroundColor DarkRed
        }
        else
        {
            Write-Host "Deleted $directory" -ForegroundColor Green
        }
    }
    else {
        Write-Host "Nothing to delete" -ForegroundColor Yellow
    }
}
