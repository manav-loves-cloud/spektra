New-Item -ItemType directory -Path C:\AllFiles
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://github.com/himanshuahlawat31/udacity-esnd/raw/main/Esnd-4.zip","C:\AllFiles\AllFiles.zip")
Expand-Archive -LiteralPath C:\AllFiles\AllFiles.zip -DestinationPath C:\AllFiles