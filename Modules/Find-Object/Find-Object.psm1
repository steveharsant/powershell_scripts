# A better find tool
function Find-Object {
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $name,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $path,

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [switch]
        $recurse
    )

    if([String]::IsNullOrEmpty($path))
    {
        $path = (Get-Location).path
    }

    if([String]::IsNullOrEmpty($name) -and [String]::IsNullOrEmpty($type))
    {
        Write-Host "You probably don't want to return everything, do you?" -ForegroundColor Yellow
        break
    }

    if ($recurse.IsPresent)
    {
        Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | Where-Object {($_.name -match "$type") -and ($_.name -match "$name")}
    }
    else {
        Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Where-Object {$_.name -match "$name"}
    }
}
