function Initialize-KitchenConverge {
    param (
        $runlist
    )
    Clear-Host
    kitchen converge $runlist
    New-BurntToastNotification -AppLogo C:\Users\$env:USERNAME\Pictures\chef_icon.png -Text "Kitchen Converge Complete!", 'Were there errors? ...probably!'
}

Set-Alias converge Initialize-KitchenConverge
export-modulemember -alias * -function *
