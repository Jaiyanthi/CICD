#
# Filename: ImportSolution.ps1.
#
param(
$dllPath,
$solutionListFile,
$solutionImportPath,
$crmConnectionString,
$override,
$publishWorkflows,
$overwriteUnmanagedCustomizations,
$skipProductUpdateDependencies,
$convertToManaged,
$holdingSolution,
$AsyncWaitTimeout,
$logsDirectory,
$logFilename
)

$ErrorActionPreference = "Stop"

Write-Verbose 'Entering ImportSolution.ps1'
 Write-Output $dllPath
$path1=Join-Path -Path $dllPath -ChildPath "Microsoft.Xrm.Sdk.dll"
$path2=Join-Path -Path $dllPath -ChildPath "Microsoft.Crm.Sdk.Proxy.dll"
$path3=Join-Path -Path $dllPath -ChildPath "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
$path4=Join-Path -Path $dllPath -ChildPath "Microsoft.Xrm.Sdk.Deployment.dll"
$path5=Join-Path -Path $dllPath -ChildPath "Microsoft.Xrm.Tooling.Connector.dll"
$path6=Join-Path -Path $dllPath -ChildPath "Xrm.Framework.CI.PowerShell.Cmdlets.dll"
$path7=Join-Path -Path $dllPath -ChildPath "Xrm.Framework.CI.Common.dll"

Write-Output $path1

if(-Not (Get-Module -ListAvailable -Name Xrm.Framework.CI.PowerShell.Cmdlets))
{


[void][System.Reflection.Assembly]::LoadFile($path1)
[void][System.Reflection.Assembly]::LoadFile($path2)
[void][System.Reflection.Assembly]::LoadFile($path3)
[void][System.Reflection.Assembly]::LoadFile($path4)
[void][System.Reflection.Assembly]::LoadFile($path5)
[void][System.Reflection.Assembly]::LoadFile($path6)
[void][System.Reflection.Assembly]::LoadFile($path7)
}

Write-Host $solutionImportPath
Write-Host $solution
Write-Host $solutionListFile



foreach($file in Get-ChildItem -Path $solutionImportPath)
{
$solutionInfo = Get-XrmSolutionInfoFromZip -SolutionFilePath $file.FullName

    Write-Host "Solution Name: " $solutionInfo.UniqueName
    Write-Host "Solution Version: " $solutionInfo.Version

    
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    $solution = Get-XrmSolution -ConnectionString "$crmConnectionString" -UniqueSolutionName $solutionInfo.UniqueName

    if ($solution -eq $null)
    {
        Write-Host "Solution not currently installed"
    }
    else
    {
        Write-Host "Solution Installed Current version: " $solution.Version
    }
    
    if ($override -or ($solution -eq $null) -or ($solution.Version -ne $solutionInfo.Version))
    {    
        Write-Verbose "Importing Solution: $solutionFile"

        $importJobId = [guid]::NewGuid()
    
        $asyncOperationId = Import-XrmSolution -ConnectionString "$crmConnectionString" -SolutionFilePath $file.FullName -publishWorkflows $publishWorkflows -overwriteUnmanagedCustomizations $overwriteUnmanagedCustomizations -SkipProductUpdateDependencies $skipProductUpdateDependencies -ConvertToManaged $convertToManaged -HoldingSolution $holdingSolution -ImportAsync $true -ImportJobId $importJobId -AsyncWaitTimeout $AsyncWaitTimeout -Verbose
   
        Write-Host "Solution Import Completed. Import Job Id: $importJobId"

        if ($logsDirectory)
        {
            if ($logFilename)
            {
                $importLogFile = $logsDirectory + "\" + $logFilename
            }
            else
            {
                $importLogFile = $logsDirectory + "\" + $solutionInfo.UniqueName + '_' + ($solutionInfo.Version).replace('.','_') + '_' + [System.DateTime]::Now.ToString("yyyy_MM_dd__HH_mm") + ".xml"
            }
        }

        $importJob = Get-XrmSolutionImportLog -ImportJobId $importJobId -ConnectionString "$CrmConnectionString" -OutputFile "$importLogFile"

        $importProgress = $importJob.Progress
        $importResult = (Select-Xml -Content $importJob.Data -XPath "//solutionManifest/result/@result").Node.Value
        $importErrorText = (Select-Xml -Content $importJob.Data -XPath "//solutionManifest/result/@errortext").Node.Value

        Write-Verbose "Import Progress: $importProgress"
        Write-Verbose "Import Result: $importResult"
        Write-Verbose "Import Error Text: $importErrorText"
        Write-Verbose $importJob.Data

            if ($importResult -ne "success")
        {
            throw "Import Failed"
        }

        #parse the importexportxml and look for result notes with result="failure"
        $importFailed = $false
        $importjobXml = [xml]$importJob.Data
        $failureNodes = $importjobXml.SelectNodes("//*[@result='failure']")

        foreach ($failureNode in $failureNodes){
            $componentName = $failureNode.ParentNode.Attributes['name'].Value
            $errorText = $failureNode.Attributes['errortext'].Value
            Write-Host "Component Import Failure: '$componentName' failed with error: '$errorText'"
            $importFailed = $true
        }
            
        if ($importFailed -eq $true)
        {   
            throw "The Solution Import failed because one or more components with a result of 'failure' were found. For detals, check the Diagnostics for this build or the solution import log file in the logs subfolder of the Drop folder."
        }
        else
        {
           Write-Host "The import result of all components is 'success'."
        }
        #end parse the importexportxml and look for result notes with result="failure"
                                              
        $solution = Get-XrmSolution -ConnectionString "$CrmConnectionString" -UniqueSolutionName $solutionInfo.UniqueName

        if ($solution.Version -ne $solutionInfo.Version) 
        {
            throw "Import Failed. Check the solution import log file in the logs subfolder of the Drop folder."
        }
        else
        {
            Write-Host "Solution Imported Successfully"
        }
    }
    else
    {
        Write-Host "Skipped Import of Solution..."
    }
}
Write-Verbose 'Leaving ImportSolution.ps1'

#NOTE :- $ solutionListFile , $solutionImportPath need to be passed to ps1 script as argument.
