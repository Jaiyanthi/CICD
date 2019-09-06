#
# Filename: SolutionToBeImported.ps1.
#
param(
$solutionListFile
)
        foreach($solution in [System.IO.File]::ReadLines($solutionListFile)){
$solutionFileName +=  "$solution" + ";"
        }

$newlineDelimited = $solutionFileName -replace ';', "%0D%0A"

Write-Host "##vso[task.setvariable variable=SolutionsFileName]$newlineDelimited"
