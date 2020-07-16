function Get-AllGitBranches {
    Param(
      [Parameter(Mandatory=$false)]
      [String]
      $parent
    )

    # Set path script was called from to be returned to after run
    $startingPath = (Get-Location).path

    # Get sub directories from the parent
    $repositories = Get-ChildItem -Path $parent

    # Print information
    Write-Output ''
    Write-Output "Generating list of open branches for repositories found under: $parent"
    Write-Output '---'
    Write-Output ''

    # Loop through directories
    foreach ($repo in $repositories) {
        Set-Location "$parent\$($repo.Name)"

        # Get branch info
        $branches = git branch

        # If there are more branches than just 'master', write repo name...
        if($branches -ne '* master')
        {
          Write-Host $repo.Name -BackgroundColor DarkMagenta -ForegroundColor White

          foreach ($branch in $branches) {

            # Branch output formatting
            $characterCount = ($branch | Measure-Object -Character).characters
            $characterCount = 50 - $characterCount
            $branchName = $branch -replace(' ', '')

            # Get timestamp from last action on branch and format time based off Unix epoch
            $branchInfo = Get-Content -Path "$parent\$($repo.Name)\.git\logs\refs\heads\$branchName" -Tail 1
            $branchInfo -match '.+ ([0-9]+)' | out-null
            $epochTime = $matches[1]
            $formattedTime = (Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($epochTime))

            # Calculate and set spacing for visual formatting
            $n = 0
            do {
              $spaceFormatting = $spaceFormatting + ' '
              $n++
            } until ($n -eq $characterCount)

            # Print output in green if it is the current checked-out branch
            if($branch -match "\*")
            {
              Write-Host $branch $spaceFormatting $formattedTime.ToUniversalTime() -ForegroundColor Green
            }
            else {

              # Print output in red if the branch hasn't been touched in more than 3 months
              if($formattedTime -lt (Get-Date).AddMonths(-3))
              {
                Write-Host $branch $spaceFormatting $formattedTime.ToUniversalTime() -ForegroundColor DarkRed
              }
              # Print output in dark yellow if the branch hasn't been touched in more than 1 month
              elseif($formattedTime -lt (Get-Date).AddMonths(-1))
              {
                Write-Host $branch $spaceFormatting $formattedTime.ToUniversalTime() -ForegroundColor DarkYellow
              }
              # Print output without colours if touched in >1 month
              else{
                Write-Host $branch $spaceFormatting $formattedTime.ToUniversalTime()
              }
            }
            # reset space formatting
            $spaceFormatting = $null
          }
            Write-Output " "
        }
    }

    # Go back to directory script was called from
    Set-Location $startingPath
    }
