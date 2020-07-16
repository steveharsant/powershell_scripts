# A better remove file/directory tool as it does not prompt to confirm
#
# Add the following lines (uncommented) to your Powershell profile to remap rm alias
# Remove-Item Alias:rm -Force
# New-Alias rm Remove-Object
function Remove-Object {
    param (
        $path
    )

    Remove-Item $path -Recurse -Confirm:$false -Force
}
