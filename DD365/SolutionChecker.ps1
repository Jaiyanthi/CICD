#

# Filename: SolutionChecker.ps1.

#



                           Param([string] $clientAppId,

                                [string] $tenantId,                               

                                [string]  $resultOutputDirectory,

                                [string]  $ClientApplicationSecret,

                                [string]  $rootPath

                                )

$Secure2 = ConvertTo-SecureString -String $ClientApplicationSecret -AsPlainText -Force

Write-Output $clientAppId

Write-Output $tenantId

Write-Output $resultOutputDirectory

Write-Output $Secure2

Write-Output $rootPath

$ErrorActionPreference = "Stop"

Write-Verbose 'Entering SolutionChecker.ps1'

if (Get-Module -ListAvailable -Name Microsoft.PowerApps.Checker.PowerShell)

                                {

                                Write - Output 'Microsoft.PowerApps.Checker.PowerShell Module exists'

                                }

                                else {

                                Write-Output 'Microsoft.PowerApps.Checker.PowerShell Module not exists'

                                Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

                                Write-Output('Installing Microsoft.PowerApps.Checker.PowerShell module')

                                Install-Module Microsoft.PowerApps.Checker.PowerShell -Scope CurrentUser

                                Write-Output('Module installed successfully');

                                }

                                if (-not([string]::IsNullOrEmpty($clientAppId)) -and -not([string]::IsNullOrEmpty($tenantId)) -and -not([string]::IsNullOrEmpty($rootPath)) -and -not([string]::IsNullOrEmpty($resultOutputDirectory)))
                                {

                                $ruleSet = Get-PowerAppsCheckerRulesets -Geography India

                                $ruleSetToUse = $ruleSet | where Name -EQ 'Solution Checker'

                                Write-Output('Started analysing solution results')

                             $DFSFolders = get-childitem -path $rootPath -filter *.zip |select-object name

                               Write-Output 'Loop through folders in Directory'
                                                         
                              foreach ($DFSfolder in $DFSfolders)
                                {
                                Write-Output $DFSfolder.Name

                                $DFSfolder = Join-Path -Path "$rootPath" -ChildPath $DFSfolder.Name
                                $result = Invoke-PowerAppsChecker -ClientApplicationId $clientAppId -FileUnderAnalysis $DFSfolder -OutputDirectory $resultOutputDirectory -Ruleset $ruleSetToUse -TenantId $tenantId -ClientApplicationSecret $Secure2 -Verbose 
                                Write-Output 'result is : '
                                Write-Output($result)
                                Write-Output($result.IssueSummary)
                                }
                                
                                }
                                else
                                {

                                Write-Output('Please fill all the required fields')

                                }

                                Write-Verbose 'Leaving SolutionChecker.ps1'
