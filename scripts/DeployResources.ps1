#------------------------------------------------------------------------
#Author: Ramya Balusamy
#Email: ramya.balusamy.b@gmail.com
#Date: 08/26/2019
#Purpose: Deploy resources to Azure using ARM templates
#Usage:
# - ClientID: Service principal app id
# - Clientkey: Service principal key
# - SubscriptionID: Azure subscription ID
# - TenantID: Azure tenant ID
# - ResourceGroupName: Name of resource group for deployment
# - Location: Location for resource group and resources
# - DeploymentName: Name of the deployment
# - TemplateFile: ARM template file path
# - ParameterFile: ARM template parameter file path
#------------------------------------------------------------------------

Param(
[string]$ClientID,
[string]$Clientkey,
[string]$SubscriptionID,
[string]$TenantID,
[string]$ResourceGroupName,
[string]$Location,
[string]$DeploymentName,
[string]$TemplateFile,
[string]$ParameterFile
)

$ErrorActionPreference = "stop"

Try{

#Authentication
$Password = $Clientkey | ConvertTo-SecureString -AsPlainText -Force
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ClientID, $Password
Connect-AzAccount -ServicePrincipal -Credential $Cred -Subscription $SubscriptionID -TenantId $TenantID


#function to deploy the resources
function Deploy-AzResources($DeploymentName, $ResourceGroupName, $TemplateFile, $ParameterFile){

New-AzResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterFile $ParameterFile -Force -SkipTemplateParameterPrompt -Verbose

}

$ResourceGroups = Get-AzResourceGroup

if ($ResourceGroups.ResourceGroupName -contains $ResourceGroupName){

Write-Host "Resource Group already exists!"

Deploy-AzResources $DeploymentName $ResourceGroupName $TemplateFile $ParameterFile

}

else{

Write-Host "Resource Group doesn't exists! Let's create new Resource Group and deploy resources"

New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag @{nordcloud="nordcloud assessment"} -Force -Verbose

Deploy-AzResources $DeploymentName $ResourceGroupName $TemplateFile $ParameterFile

}

}

Catch{

$ErrorMessage = $_.Exception.Message

$ErrorMessage

}