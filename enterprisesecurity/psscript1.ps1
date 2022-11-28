param(
	    [Parameter(Mandatory=$true)]
        [String]$domain,
        [Parameter(Mandatory=$true)]
        [String]$subId,
        [Parameter(Mandatory=$true)]
        [String]$username,
		[Parameter(Mandatory=$true)]
        [String]$password,
		[Parameter(Mandatory=$true)]
        [String]$deployID
 )

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
#Import Common Functions
$path = pwd
$path=$path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

# Run Imported functions from cloudlabs-windows-functions.ps1

InstallChocolatey

Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose

$WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\ MLstudio.lnk")
        $Shortcut.TargetPath = """C:\Program Files\Google\Chrome\Application\chrome.exe"""
        $argA = """https://ml.azure.com"""
        $Shortcut.Arguments = $argA 
        $Shortcut.Save()


New-Item -ItemType directory -Path C:\udacity
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://github.com/CloudLabsAI-Azure/Udacity/raw/main/MLND/files/Notebooks.zip"," C:\udacity\Notebook.zip")
#unziping folder
function Expand-ZIPFile($file, $destination)
{
$shell = new-object -com shell.application
$zip = $shell.NameSpace($file)
foreach($item in $zip.items())
{
$shell.Namespace($destination).copyhere($item)
}
}
Expand-ZIPFile -File "C:\udacity\Notebook.zip" -Destination "C:\Users\demouser\Desktop\"



$FileDir ="C:\Packages"
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/udacity-nanodegree/scripts/schedule.ps1","C:\Packages\schedule.ps1")
$WebClient.DownloadFile("https://experienceazure.blob.core.windows.net/templates/udacity-nanodegree/scripts/creds.txt","C:\Packages\creds.txt")


(Get-Content -Path "$FileDir\creds.txt") | ForEach-Object {$_ -Replace "domainValue", "$domain"} | Set-Content -Path "$FileDir\creds.txt"
(Get-Content -Path "$FileDir\creds.txt") | ForEach-Object {$_ -Replace "usernamevalue", "$username"} | Set-Content -Path "$FileDir\creds.txt"
(Get-Content -Path "$FileDir\creds.txt") | ForEach-Object {$_ -Replace "passwordvalue", "$password"} | Set-Content -Path "$FileDir\creds.txt"
(Get-Content -Path "$FileDir\creds.txt") | ForEach-Object {$_ -Replace "SubscriptionIdValue", "$subId"} | Set-Content -Path "$FileDir\creds.txt"
(Get-Content -Path "$FileDir\creds.txt") | ForEach-Object {$_ -Replace "deployvalue", "$deployID"} | Set-Content -Path "$FileDir\creds.txt"

$adminUsername="demouser"
$adminPassword="Password123!"



$AutoLogonRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoAdminLogon" -Value "1" -type String 
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultUsername" -Value "$($env:ComputerName)\$adminUsername" -type String  
Set-ItemProperty -Path $AutoLogonRegPath -Name "DefaultPassword" -Value "$adminPassword" -type String
Set-ItemProperty -Path $AutoLogonRegPath -Name "AutoLogonCount" -Value "1" -type DWord

reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v PasswordManagerEnable /t REG_DWORD /d 0
#scheduled task
$Trigger= New-ScheduledTaskTrigger -AtLogOn
$User= "$($env:ComputerName)\$adminUsername" 
$Action= New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-executionPolicy Unrestricted -File $FileDir\schedule.ps1"
Register-ScheduledTask -TaskName "startextension" -Trigger $Trigger  -User $User -Action $Action -RunLevel Highest -Force


cd HKLM:\
New-Item –Path "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Network\" –Name NewNetworkWindowOff


Restart-Computer
