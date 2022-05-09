[CmdletBinding()]
param (
  [Parameter()][string] $templateDirectory = "$env:USERPROFILE\Documents\Declarations\templates",
  [Parameter()][string] $outputBaseDirectory = "$env:USERPROFILE\Documents\Declarations"
)


# This script does a simple find and replace of doc(x) and xls(x) files in a directory.
# It replaces the DECLARATION_PERIOD with Qx YYYY (where x is the previous quarter and YYYY is the matching year)
# TODAYS_DATE is also replaced with today's date as dd/mm/yyyy
# This script then converts the Excel or Word files to PDF files
# A template folder with the declaration templates needs to be specified if not in the default directory, and
# the templates need to contain TODAYS_DATE or DECLARATION_PERIOD in the files contents

function Write-Debug($message) { Write-Host "[debug] $message" -ForegroundColor Blue }
function Write-Log($message) { Write-Host "[log] $message" -ForegroundColor Yellow }

# Add .Net assemble for filesystem as Expand-Archive fails to unzip Office docs
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Derive quarter from month
switch ((Get-Date -Format '%M')) {
  { $_ -in 1..3 } { $quarter = 'Q4'; $year = $year - 1 }
  { $_ -in 4..6 } { $quarter = 'Q1' }
  { $_ -in 7..9 } { $quarter = 'Q2' }
  { $_ -in 10..12 } { $quarter = 'Q3' }
}

# Set variables
$year = [int](Get-Date -Format 'yyyy')
$destinationDirectory = "$outputBaseDirectory/$year/$quarter"
$tempPath = "$templateDirectory/temp"
$templates = Get-ChildItem -Path $templateDirectory

# Write debug messages
Write-Debug "year: $year"
Write-Debug "quarter: $quarter"
Write-Debug "destinationDirectory: $destinationDirectory"
Write-Debug "templateDirectory: $templateDirectory"
Write-Debug "tempPath: $tempPath"
Write-Debug "templates: $($templates.FullName)"

# Create directories
New-Item -Path $destinationDirectory -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

if (Test-Path $tempPath) { Remove-Item -Path $tempPath -Recurse -Force -Confirm:$false }
else { New-Item -Path $tempPath -ItemType Directory | Out-Null }

# Iterate over template files
foreach ($template in $templates) {

  Write-Host "Expanding $template" -ForegroundColor Green
  [System.IO.Compression.ZipFile]::ExtractToDirectory($template.FullName, "$tempPath/$template")

  # Iterate over files in the templates expanded directory
  # Need to filter out [Content_Types].xml as it throws when iterating over
  $files = Get-ChildItem -Path "$tempPath/$template" -Recurse -File |
  Where-Object { $_.Name -ne '[Content_Types].xml' } |
  Where-Object { $_.FullName -notmatch 'media' }

  Write-Log 'Running find/replace on files'

  foreach ($file in $files) {

    $fileContents = Get-Content -Path $file.FullName
    $fileContents = $fileContents.Replace('DECLARATION_PERIOD', "$quarter $year")
    $fileContents = $fileContents.Replace('TODAYS_DATE', (Get-Date -Format 'dd/MM/yyyy'))

    Set-Content -Path $file.FullName -Value $fileContents
  }

  Write-Log "Zipping $template"
  [System.IO.Compression.ZipFile]::CreateFromDirectory("$tempPath/$template", "$destinationDirectory/$quarter $year $template" )

  Write-Log 'Converting Office file to PDF'

  $pdfFileName = $template.Name.Replace('.docx', '.pdf').Replace('.xlsx', '.pdf')

  if ( ($template.Name -match '.docx') -or ($template.Name -match '.doc') ) {

    $officeObject = New-Object -ComObject Word.Application
    $document = $officeObject.Documents.Open("$destinationDirectory/$quarter $year $template")
    $document.SaveAs([ref] "$destinationDirectory/$quarter $year $pdfFileName", [ref] 17)
    $document.Close()
    $officeObject.Quit()

  } elseif ( ($template.Name -match '.xlsx') -or ($template.Name -match '.xls') ) {

    $officeObject = New-Object -ComObject Excel.Application
    $officeObject.visible = $false
    $xlFixedFormat = 'Microsoft.Office.Interop.Excel.xlFixedFormatType' -as [type]

    $workbook = $officeObject.workbooks.open("$destinationDirectory/$quarter $year $template")
    $worksheet = $officeObject.worksheets.item(1)
    $worksheet.ExportAsFixedFormat($xlFixedFormat::xlTypePDF, "$destinationDirectory/$quarter $year $pdfFileName")

    $officeObject.Workbooks.close()
    $officeObject.Quit()

  } else { Write-Host 'Filetype not supported for pdf conversion' -ForegroundColor Red }

}

Write-Host 'Cleaning up temporary files'

try {
  Remove-Item -Path "$templateDirectory/temp" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
} catch {
  Write-Host "Failed to clean temp directory. Manually delete: $tempPath" -ForegroundColor Red
}
