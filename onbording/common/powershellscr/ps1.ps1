
New-Item -ItemType directory -Path C:\AllFiles
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://github.com/himanshuahlawat31/udacity-esnd/raw/main/Esnd-4.zip","C:\AllFiles\AllFiles.zip")
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
