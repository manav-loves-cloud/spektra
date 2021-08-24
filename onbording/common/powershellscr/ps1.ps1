New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\" -Name "Reliability" –Force
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability' `
                 -Name ShutdownReasonOn `
                 -Value 0x00000000 `
                 -PropertyType DWORD `
                 -Force


New-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows NT\" -Name "Reliability" –Force
New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows NT\Reliability' `
                 -Name ShutdownReasonOn `
                 -Value 0x00000000 `
                 -PropertyType DWORD `
                 -Force
sleep 5

#Download git repository 
New-Item -ItemType directory -Path C:\AllFiles
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://github.com/MicrosoftLearning/AZ-304-Microsoft-Azure-Architect-Design/archive/master.zip","C:\AllFiles\AllFiles.zip")
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
Expand-ZIPFile -File "C:\AllFiles\AllFiles.zip" -Destination "C:\AllFiles\"