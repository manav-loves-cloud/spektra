
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


[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

#import common functions
Set-ExecutionPolicy -ExecutionPolicy unrestricted -Force

$commonscriptpath = "C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension\1.10.12\Downloads\0" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath


InstallChocolatey
InstallAzCLI
CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID
 $upadminPassword



Clear-Host 
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
