Start-Transcript -Path C:\WindowsAzure\Logs\logon.txt -Append

CD C:\LabFiles

$credsfilepath = ".\AzureCreds.txt"
$creds = Get-Content $credsfilepath | Out-String | ConvertFrom-StringData
$AzureUserName = "$($creds.AzureUserName)"
$AzurePassword = "$($creds.AzurePassword)"
$DeploymentID = "$($creds.DeploymentID)"
$AzureSubscriptionID = "$($creds.AzureSubscriptionID)"
$passwd = ConvertTo-SecureString $AzurePassword -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AzureUserName, $passwd
$subscriptionId = $AzureSubscriptionID

$workspacename= "loanmodel"+$DeploymentID

Connect-AzAccount -Credential $cred | Out-Null

#Running the synapse1 pipline
Set-AzSynapseLinkedService -WorkspaceName $WorkspaceName -Name link_to_sbadata_storage -DefinitionFile "C:\LabFiles\Clean_Raw_Data_support_live\linkedService\link_to_sbadata_storage.json"
Set-AzSynapseLinkedService -WorkspaceName $WorkspaceName -Name loandemo_datalake -DefinitionFile "C:\LabFiles\Clean_Raw_Data_support_live\linkedService\loandemo_datalake.json"

sleep 10

Set-AzSynapseDataset -WorkspaceName $WorkspaceName  -Name SBA_Raw_Data -DefinitionFile "C:\LabFiles\Clean_Raw_Data_support_live\dataset\SBA_Raw_Data.json"
Set-AzSynapseDataset -WorkspaceName $WorkspaceName  -Name SBA_input_data -DefinitionFile "C:\LabFiles\Clean_Raw_Data_support_live\dataset\SBA_input_data.json"
Set-AzSynapseDataset -WorkspaceName $WorkspaceName  -Name NAICS_data -DefinitionFile "C:\LabFiles\Clean_Raw_Data_support_live\dataset\NAICS_data.json"
Set-AzSynapseDataset -WorkspaceName $WorkspaceName  -Name LoanRawData -DefinitionFile "C:\LabFiles\Clean_Raw_Data_support_live\dataset\LoanRawData.json"
Set-AzSynapseDataset -WorkspaceName $WorkspaceName  -Name LoanCuratedData -DefinitionFile "C:\LabFiles\Clean_Raw_Data_support_live\dataset\LoanCuratedData.json"

sleep 10

Set-AzSynapseDataFlow -WorkspaceName $WorkspaceName -Name Clean_Loan_Raw_Data -DefinitionFile "C:\LabFiles\Clean_Raw_Data_support_live\dataflow\Clean_Loan_Raw_Data.json"

sleep 10

Set-AzSynapsePipeline -WorkspaceName $WorkspaceName -Name Clean_Raw_Data -DefinitionFile "C:\LabFiles\Clean_Raw_Data_support_live\pipeline\Clean_Raw_Data.json"

sleep 10

$HeadersInfo = Invoke-AzSynapsePipeline -WorkspaceName $WorkspaceName -PipelineName "Clean_Raw_Data"
$HeadersInfo
$HeadersRunID=$HeadersInfo.RunId

sleep 600

#Running the spark note book

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/bhavangowdan/spektra/main/loanmodelling/Notebook%201.ipynb","C:\LabFiles\Notebook1.ipynb")
$WebClient.DownloadFile("https://raw.githubusercontent.com/bhavangowdan/spektra/main/loanmodelling/Pipeline%201.json","C:\LabFiles\Pipeline1.json")

(Get-Content -Path "C:\LabFiles\Notebook1.ipynb") | ForEach-Object {$_ -Replace 'DID', $DeploymentID} | Set-Content -Path "C:\LabFiles\Notebook1.ipynb"


sleep 100

Set-AzSynapseNotebook -WorkspaceName $workspacename -Name notebook1 -DefinitionFile "C:\LabFiles\Notebook1.ipynb"

Set-AzSynapsePipeline -WorkspaceName $workspacename -Name pipeline1 -DefinitionFile "C:\LabFiles\Pipeline1.json"


Invoke-AzSynapsePipeline -WorkspaceName $workspacename -PipelineName pipeline1

sleep 600
