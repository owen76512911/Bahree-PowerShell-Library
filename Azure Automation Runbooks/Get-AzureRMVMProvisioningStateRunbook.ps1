<#PSScriptInfo
.VERSION 1.1.0
.GUID 1db477bb-b7e1-4a4a-a398-b7f2b2d9a376
.AUTHOR Arjun Bahree
.COMPANYNAME 
.COPYRIGHT (c) 2018 Arjun Bahree. All rights reserved.
.TAGS Windows PowerShell Azure AzureAutomation Runbooks AzureVM
.LICENSEURI https://github.com/bahreex/Bahree-PowerShell-Library/blob/master/LICENSE
.PROJECTURI https://github.com/bahreex/Bahree-PowerShell-Library/tree/master/Azure%20Automation%20Runbooks
.ICONURI 
.EXTERNALMODULEDEPENDENCIES AzureRM
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
#>

<# 
.DESCRIPTION 
 Gets you the current Provisioning State of an Azure RM VM as a Runbook from within an Azure Automation Account.
#> 

<#
.SYNOPSIS 
    Gets you the current Provisioning State of an Azure RM VM as a Runbook from within an Azure Automation Account.

.DESCRIPTION
    This Runbook returns to you current Provisioning State of an Azure RM VM. You need to execute this Runbook through 
    a 'Azure Run As account (service principal)' Identity from an Azure Automation account.

.PARAMETER ResourceGroupName
    Name of the Resource Group containing the VM

.PARAMETER VMName    
    Name of the VM whose Provisioning State you want to retrieve

.EXAMPLE
    .\Get-AzureRMVMProvisioningState.ps1 -ResourceGroupName "RG1" -VMName "VM01"
    
.Notes

Possible VM Provisioning State Values (Model View):

- Creating	:Indicates the virtual Machine is being created.
- Updating	:Indicates that there is an update operation in progress on the Virtual Machine.
- Succeeded	:Indicates that the operation executed on the virtual machine succeeded.
- Deleting	:Indicates that the virtual machine is being deleted.
- Failed	:Indicates that the update operation on the Virtual Machine failed.


Author: Arjun Bahree
E-mail: arjun.bahree@gmail.com
Creation Date: 10/Jan/2018
Last Revision Date: 15/Jan/2018
Development Environment: Azure Automation Runbook Editor and VS Code IDE
PS Version: 5.1
Platform: Windows
#>

param(

    [Parameter(Mandatory=$true)] 
    [String]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)] 
    [String]$VMName
)

if (!(Get-AzureRmContext).Account) {
    $connectionName = "AzureRunAsConnection"
    try {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         
    
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint > $null
    }
    catch {
        if (!$servicePrincipalConnection) {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        }
        else {
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
}

# Get the VM in context
$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName

if ($vm)
{
    # Get current status of the VM
    $vmstatus = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VMName -Status

    # Extract current Provisioning State of the VM
    $provState = $vmstatus.Statuses[0].Code.Split('/')[1]

    # Return the Provisioning State
    return $provState.ToUpper()

}
else {
    Write-Error "Cannot find VM'"
    return 
}
