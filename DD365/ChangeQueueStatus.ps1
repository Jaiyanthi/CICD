#[void][System.Reflection.Assembly]::LoadFile("D:\PS to save entity\microsoft.xrm.sdk.dll")

#[void][System.Reflection.Assembly]::LoadFile("D:\PS to save entity\microsoft.crm.sdk.proxy.dll")



                            Param(
                                [string] $crmServiceUrl,                            
                                [string]  $UserName,
                                [string]  $Password,
                                [string]  $Status,
                                [string]  $resultFileUrls,
                                tring]  $buildurl,
                                tring]  $releaseurl,
                                [string]  $EntityRecordId
                               
                                )
Write-Output $crmServiceUrl
Write-Output $UserName
Write-Output $Password
Write-Output $Status
Write-Output $resultFileUrls 
Write-Output $buildurl
Write-Output $releaseurl
Write-Output $EntityRecordId


if(-Not (Get-Module -ListAvailable -Name Xrm.Framework.CI.PowerShell.Cmdlets))
{
Import-Module $env:DOWNLOADSECUREFILE1_SECUREFILEPATH
Import-Module $env:DOWNLOADSECUREFILE2_SECUREFILEPATH
}
[void][System.Reflection.Assembly]::LoadWithPartialName("system.servicemodel")

$clientCredentials = new-object System.ServiceModel.Description.ClientCredentials

$clientCredentials.UserName.UserName =  $UserName

$clientCredentials.UserName.Password = $Password

$service = new-object Microsoft.Xrm.Sdk.Client.OrganizationServiceProxy($crmServiceUrl, $null, $clientCredentials, $null)

$service.Timeout = new-object System.Timespan(0, 10, 0);

$request = new-object Microsoft.Crm.Sdk.Messages.WhoAmIRequest

$service.Execute($request)

$query = new-object Microsoft.Xrm.Sdk.Query.QueryExpression("syed_sourcecontrolqueue")

$query.ColumnSet = new-object Microsoft.Xrm.Sdk.Query.ColumnSet($true)

# RetrieveMultiple returns a maximum of 5000 records by default. 

# If you need more, use the response's PagingCookie.

$response = $service.RetrieveMultiple($query)

Write-Output  $response   #{955715C8-79D4-E911-A812-000D3A0A7552}

## need to chane the status for record build com0-lete , release compoleted

    $entity = New-Object Microsoft.Xrm.Sdk.Entity("syed_sourcecontrolqueue")

    $entity.Id = $EntityRecordId; #"955715C8-79D4-E911-A812-000D3A0A7552"

    if (-not([string]::IsNullOrEmpty($Status)))
      {
      $entity.Attributes["syed_status"] =$Status;
     }
    
    if (-not([string]::IsNullOrEmpty($resultFileUrls)))
      {
      $entity.Attributes["syed_solutionchecker"] =$resultFileUrls;
     }
    if (-not([string]::IsNullOrEmpty($buildurl)))
      {
      $entity.Attributes["syed_devopsbuildurl"] =$buildurl;
     }
    if (-not([string]::IsNullOrEmpty($releaseurl)))
      {
      $entity.Attributes["syed_devopsreleaseurl"] =$releaseurl;
     }
     
    #Write-Output ('Updating "{0}" (Id = {1})...' -f $_.name, $entity.Id)

    $service.Update($entity)
