Param (
    [Parameter(Mandatory = $true)]    
    [string]
    $adminPassword
    )

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append

$adminUsername= "cyberadmin"
net user $adminUsername $adminPassword
