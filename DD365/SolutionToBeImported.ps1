#
# Filename: SolutionToBeImported.ps1.
#
param(
$solutionListFile,
$configListFile
)
        foreach($solution in [System.IO.File]::ReadLines($solutionListFile)){
$solutionFileName +=  "$solution" + ";"
        }

		foreach($sourceControlId in [System.IO.File]::ReadLines($configListFile)){
$dynamicsSourceControlId +=  "$sourceControlId" + ";"
        }

$newlineDelimited = $solutionFileName -replace ';', "%0D%0A"
$newlineDelimitedConfigValue = $dynamicsSourceControlId -replace ';', "%0D%0A"

Write-Output $newlineDelimited
Write-Output $newlineDelimitedConfigValue

Write-Host "##vso[task.setvariable variable=SolutionsFileName]$newlineDelimited"
Write-Host "##vso[task.setvariable variable=ConfigIds]$newlineDelimitedConfigValue"
