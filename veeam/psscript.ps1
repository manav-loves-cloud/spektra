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
    $ODLID,

    [string]
    $DeploymentID,

    [string]
    $InstallCloudLabsShadow
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

#Import Common Functions
$path = pwd
$path=$path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

# Run Imported functions from cloudlabs-windows-functions.ps1
WindowsServerCommon
InstallCloudLabsShadow $ODLID $InstallCloudLabsShadow
CreateCredFile $AzureUserName $AzurePassword $AzureTenantID $AzureSubscriptionID $DeploymentID

Set-ExecutionPolicy -ExecutionPolicy bypass -Force




Set-ExecutionPolicy -ExecutionPolicy unrestricted -Force




Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Set-PSRepository -Name "PSGallery" -Installationpolicy Trusted

Install-Module -Name Az -AllowClobber -Scope AllUsers -Force

Start-Sleep -s 10

Import-Module -Name Az

Start-Sleep -s 10


 . C:\LabFiles\AzureCreds.ps1


$userName = $AzureUserName # READ FROM FILE
$password = $AzurePassword # READ FROM FILE
$Sid = $AzureSubscriptionID # READ FROM FILE
$deployId = $DeploymentID


$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName, $SecurePassword



Connect-AzAccount -Credential $cred | Out-Null

$storagename = "veeamstr"+ $deployId


$ctx=(Get-AzStorageAccount -ResourceGroupName veeam -Name $storagename).Context

##enabling service end point to virtual network
Get-AzVirtualNetwork -Name veeamvm-vnet -ResourceGroupName veeam | Set-AzVirtualNetworkSubnetConfig -Name default -AddressPrefix "10.1.0.0/24" -ServiceEndpoint "Microsoft.Storage","Microsoft.Sql" | Set-AzVirtualNetwork



##creating the storage container
$storage = Get-AzStorageAccount -ResourceGroupName veeam -Name $storagename
$storageContext = $storage.Context
New-AzStorageContainer -Context $storageContext -Name veeamcontainer -Permission Container -ErrorAction Ignore

##creating the file share
New-AzStorageShare -Context $storageContext -Name myshare
New-AzStorageDirectory -Context $storageContext -ShareName myshare -Path "Veeam"


##download and upload the file share
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/bhavangowdan/spektra/main/veeam/file1.txt","C:\LabFiles\file1.txt")


Set-AzStorageFileContent -ShareName "myshare" -Source "C:\LabFiles\file1.txt" -Path "Veeam/" -Context $storageContext -Force


##Enabling the virtual network rule and firewall rule for sql server
$servercontext = Get-AzResource -ResourceGroupName veeam -ResourceType "Microsoft.Sql/servers"
$servername = $servercontext.Name
$subnetid="/subscriptions/$Sid/resourceGroups/veeam/providers/Microsoft.Network/virtualNetworks/veeamvm-vnet/subnets/default"
New-AzSqlServerVirtualNetworkRule -ResourceGroupName veeam -ServerName $servername -VirtualNetworkRuleName virtualNetworkRuleName -VirtualNetworkSubnetId $subnetid

New-AzSqlServerFirewallRule -ResourceGroupName veeam -ServerName $servername -AllowAllAzureIPs




