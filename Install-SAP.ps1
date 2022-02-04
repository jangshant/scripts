$sourcezip='https://link'
$zip='C:\TEMP\INSTALL\SAPFrontend_7.40.zip'
$installpath='C:\Program Files (x86)\SAP\FrontEnd\SAPgui\saplogon.exe'
$sourceini='https://Link'
$ini='C:\TEMP\INSTALL\saplogon.ini'
$userdir='C:\Users\*\AppData\Roaming\SAP\Common'
$folder='C:\TEMP\INSTALL\SAPFrontend_7.40'
if (Test-Path -Path $installpath -PathType Leaf)
{"SAP already Installed no need to download or expand"}
else
{
if (Test-Path -Path $zip -PathType Leaf)
{"SAP already downloaded"}
else
{
  "Create Dir"
  New-Item -ItemType Directory -Force -Path 'C:\TEMP\INSTALL\'
  "Download zip"
  Start-BitsTransfer -Source $sourcezip -Destination $zip
}
if (Test-Path -Path $folder)
{"SAP already expanded"}
else
{
  "Expand zip"
  Expand-Archive -LiteralPath $zip -DestinationPath 'C:\TEMP\INSTALL\'
}

  "Start Install"
  Start-Process -Wait -FilePath "C:\TEMP\INSTALL\SAPFrontend_7.40\Sources\Setup\NwSapSetup.exe"-ArgumentList "/package=' ENTER PACKAGE' /noDlg"
}
"Download ini"
Start-BitsTransfer -Source $sourceini -Destination $ini
"Copy ini"
Get-ChildItem $userdir | ForEach-Object {Copy-Item -Path $ini -Destination $_ -Force}
