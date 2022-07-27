
Param (
    [Parameter(Mandatory = $true)]
    [string]
    $AzureUserName,

    [string]
    $AzurePassword,

    [string]
    $AzureTenantID,

    [string]
    $AzureSubscriptionID,

    [string]
    $DeploymentID,
    
    [string]
    $upadminPassword
  )

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append 
#import common functions

 

$ErrorActionPreference = "SilentlyContinue" 
 
## Display current Status of remaining days from Grace period. 
$GracePeriod = (Invoke-WmiMethod -PATH (gwmi -namespace root\cimv2\terminalservices -class win32_terminalservicesetting).__PATH -name GetGracePeriodDays).daysleft 
Write-Host -fore Green ====================================================== 
Write-Host -fore Green 'Terminal Server (RDS) grace period Days remaining are' : $GracePeriod 
Write-Host -fore Green ======================================================   
Write-Host 
$Response = "Y" 
 
if ($Response -eq "Y") { 
## Reset Terminal Services Grace period to 120 Days 
 
$definition = @" 
using System; 
using System.Runtime.InteropServices;  
namespace Win32Api 
{ 
    public class NtDll 
    { 
        [DllImport("ntdll.dll", EntryPoint="RtlAdjustPrivilege")] 
        public static extern int RtlAdjustPrivilege(ulong Privilege, bool Enable, bool CurrentThread, ref bool Enabled); 
    } 
} 
"@  
 
Add-Type -TypeDefinition $definition -PassThru 
 
$bEnabled = $false 
 
## Enable SeTakeOwnershipPrivilege 
$res = [Win32Api.NtDll]::RtlAdjustPrivilege(9, $true, $false, [ref]$bEnabled) 
 
## Take Ownership on the Key 
$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod", [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership) 
$acl = $key.GetAccessControl() 
$acl.SetOwner([System.Security.Principal.NTAccount]"Administrators") 
$key.SetAccessControl($acl) 
 
## Assign Full Controll permissions to Administrators on the key. 
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("Administrators","FullControl","Allow") 
$acl.SetAccessRule($rule) 
$key.SetAccessControl($acl) 
 
## Finally Delete the key which resets the Grace Period counter to 120 Days. 
Remove-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod' 
 
write-host 
Write-host -ForegroundColor Red 'Resetting, Please Wait....' 
Start-Sleep -Seconds 10  
 
  } 
 
Else  
    { 
Write-Host 
Write-Host -ForegroundColor Yellow '**You Chose not to reset Grace period of Terminal Server (RDS) Licensing' 
  } 
 
## Display Remaining Days again as final status 
tlsbln.exe 
$GracePost = (Invoke-WmiMethod -PATH (gwmi -namespace root\cimv2\terminalservices -class win32_terminalservicesetting).__PATH -name GetGracePeriodDays).daysleft 
Write-Host 
Write-Host -fore Yellow ===================================================== 
Write-Host -fore Yellow 'Terminal Server (RDS) grace period Days remaining are' : $GracePost 
Write-Host -fore Yellow ===================================================== 
 
## Cleanup of Variables 
Remove-Variable * -ErrorAction SilentlyContinue

[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

Set-ExecutionPolicy -ExecutionPolicy unrestricted -Force

$commonscriptpath = "C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.12\Downloads\0" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

WindowsServerCommon
CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID

$upadminPassword


Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name "PSGallery" -Installationpolicy Trusted
Install-Module -Name Az.compute -AllowClobber -Scope AllUsers -Force
Start-Sleep -s 10
Import-Module -Name Az.compute
Start-Sleep -s 10

CD C:\LabFiles

$userName = $AzureUserName
$password = $AzurePassword
$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword

$subscriptionId = $AzureSubscriptionID 

Connect-AzAccount -Credential $cred 

$vmName = 'CYBERND0301'
$resourceGroupName = 'cyber-' + $DeploymentID
$vm = Get-AzVm -Name $vmName -ResourceGroupName $resourceGroupName
$UserName= 'cyberadmin'
$location= $vm.Location

$secureVMPassword = $upadminPassword | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($UserName, $secureVMPassword)

New-Item file1.txt
Add-content file1.txt $vmName 
Add-content file1.txt $resourceGroupName 
Add-content file1.txt $vm 
Add-content file1.txt $UserName 
Add-content file1.txt $location
Add-content file1.txt $credential 
Add-content file1.txt $upadminPassword

Set-AzVMAccessExtension -Credential $credential -Location $location -Name 'PasswordUpdate' -ResourceGroupName $resourceGroupName -TypeHandlerVersion '2.4' -VMName $vmName

#Clear-Host 
#Restart-Computer
