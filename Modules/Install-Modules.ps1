$modules = Get-ChildItem -Path "C:\Users\$env:USERNAME\Scripts\Powershell-Scripts\Modules"

foreach ($module in $modules) {
    Copy-Item -Recurse $module "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules" -ErrorAction SilentlyContinue
}
