function Get-NamedRunList {
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $cookbook,

        [Parameter(Mandatory=$true)]
        [String]
        $cookbooksDirectory,

        [Parameter(Mandatory=$true)]
        [String]
        $runlist,

        [Parameter(Mandatory=$false)]
        [switch]
        $recurse = $false
      )

    # functions
    function CapturePolicyFile {
    param (
        $filePath
    )
    $policyFileContent = Get-Content -Path $filePath
    foreach ($line in $policyFileContent) {
        if($line -match $runlist)
        {
            $capture = $true
        }
        elseif($line -match ']')
        {
            $capture = $false
        }

        if($capture -eq $true)
        {
        if(!($line -eq "named_run_list :$runlist, ["))
        {
            $line = $line.replace("'", '')
            $line = $line.replace(",", '')
            $recipeList.Add($line) | Out-Null

        }
        }
    }
    }

    # initalise arrays
    $recipeList = [System.Collections.ArrayList]@()

    CapturePolicyFile -filePath "$cookbooksDirectory\$cookbook\PolicyFile.rb"

    # write output of policy file contents
    Write-Host "The named run list $runlist contains:" -ForegroundColor Green
    foreach ($line in $recipeList) {
    Write-Host $line
    }

    if($recurse -eq $true)
    {
    foreach ($line in $recipeList)
    {
        $line -match '(\S.*)::(.*)' | Out-Null
        $cookbook = $matches[1]
        $recipe = $matches[2]

        $recipeContent = Get-Content -Path "$cookbooksDirectory\$cookbook\recipes\$recipe.rb" -ErrorAction SilentlyContinue

        $line = $line.replace(' ', '')
        Write-Host "$line includes the recipies:" -ForegroundColor Green

        foreach ($rLine in $recipeContent)
        {
            if($rLine -match 'include_recipe')
            {
            $rLine = $rLine.replace('include_recipe ', '')
            $rLine = $rLine.replace("'", '')
            Write-Host "  $rLine" -ForegroundColor DarkCyan
            }
        }

    }
    }
}
