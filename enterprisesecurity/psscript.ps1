
param(
        [Parameter(Mandatory=$true)]
        [String]
        $subId,
        
        [String]
        $username,
		
        [String]
        $password,
	
        [String]
        $deployID,
         
        [String]
        $AzureTenantID,

        [string]
        $adminPassword
 )

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append

$adminUsername= "demouser"
net user $adminUsername $adminPassword

#Import Common Functions
$path = pwd
$path=$path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

# Run Imported functions from cloudlabs-windows-functions.ps1

InstallChocolatey
WindowsServerCommon
InstallCloudLabsShadow $ODLID $InstallCloudLabsShadow
CreateCredFile $username $password $AzureTenantID $subId $deployID


