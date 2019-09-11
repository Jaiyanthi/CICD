#
# Filename: SolutionToBeImported.ps1.
#
param(
$solutionListFile
)
        foreach($solution in [System.IO.File]::ReadLines($solutionListFile)){
$DynamicsourceControlId +=  "$solution" + ";"
        }

$newlineDelimited = $DynamicsourceControlId -replace ';', "%0D%0A"

Write-Host "##vso[task.setvariable variable=DynamicsourceControlId]$newlineDelimited"