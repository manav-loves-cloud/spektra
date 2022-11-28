Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append


CD C:\Packages
$credsfilepath = ".\creds.txt"
$creds = Get-Content $credsfilepath | Out-String | ConvertFrom-StringData

$domain = "$($creds.domain)"
$username = "$($creds.username)"
$password = "$($creds.password)"
$subId = "$($creds.subId)"
$deployID = "$($creds.deployID)"





$rgName = "aml-quickstarts-" + $deployID
$url = "https://portal.azure.com/#@" + $domain + "/resource/subscriptions/" + $subId + "/resourceGroups/" + $rgname + "/providers/Microsoft.MachineLearningServices/workspaces/quick-starts-ws-" + $deployid + "/overview"
C:\CloudLabsAI\Tools\CloudLabs.VMExtension.exe $domain $subId $username $password $rgName $url
sleep 150

