$setupsource='https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe'
$setup='C:\TEMP\INSTALL\PBIDesktopSetup_x64.exe'
$installed='C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe'

if (Test-Path -Path $installed -PathType Leaf)
{"PowerBI already Installed"}
else
{
  if (Test-Path -Path $setup -PathType Leaf)
  {"PowerBI already Downloaded"}
  else
  {
    New-Item -ItemType Directory -Force -Path 'C:\TEMP\INSTALL'
    Start-BitsTransfer -Source $setupsource -Destination $setup
    
  }
  C:\TEMP\INSTALL\PBIDesktopSetup_x64.exe -q ACCEPT_EULA=1
}
