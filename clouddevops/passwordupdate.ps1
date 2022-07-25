. C:\LabFiles\passupdate.ps1
$updatedpassword=$uppassword

. C:\LabFiles\AzureCreds.ps1

az Login -u  $AzureUserName -p $AzurePassword

az vm user update -u cyberadmin -p $updatedpassword -n CYBERND0301 -g cyber-$DeploymentID
