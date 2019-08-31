#===========================================================================#
#Description: Group the resources based on the tags
#Author: Ramya Balusamy
#Date: 08/28/2019
#===========================================================================#

param(

[Parameter(Mandatory=$True)]
 [string]
 $subscriptionId,

 [Parameter(Mandatory=$True)]
 [string]
 $resourceGroupName,

 [string]
 $tenantid,

 [string]
 $applicationId,

 [string]
 $applicationkey

)

$ErrorActionPreference = "stop"

Try{

#Authentication
$securePassword = $applicationkey | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationId, $securePassword
Connect-AzureRmAccount -ServicePrincipal -Credential $credential -Subscription $subscriptionId -TenantId $tenantid

#Group resources
(Get-AzureRmResource -TagName nordcloud).Name

}

Catch{

$ErrorMessage = $_.Exception.Message

$ErrorMessage

}


