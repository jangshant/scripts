#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Silently downloads and installs the latest Power BI Desktop (x64).
.DESCRIPTION
    Uses Microsoft's evergreen redirect so this always grabs the current release
    instead of a build pinned to one specific installer GUID.
.NOTES
    Exit code 0 = success, non-zero = failure, for RMM/Intune/SCCM detection.
#>
[CmdletBinding()]
param(
    [string]$SetupSource = 'https://aka.ms/pbisingleinstaller',
    [string]$InstallRoot = 'C:\TEMP\INSTALL'
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$setup     = Join-Path $InstallRoot 'PBIDesktopSetup_x64.exe'
$installed = 'C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe'

try {
    if (Test-Path -Path $installed -PathType Leaf) {
        Write-Host 'Power BI Desktop already installed.'
    }
    else {
        if (Test-Path -Path $setup -PathType Leaf) {
            Write-Host 'Installer already downloaded.'
        }
        else {
            Write-Host "Creating $InstallRoot"
            New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null
            Write-Host 'Downloading Power BI Desktop...'
            Start-BitsTransfer -Source $SetupSource -Destination $setup
        }

        Write-Host 'Running unattended install...'
        $proc = Start-Process -Wait -PassThru -FilePath $setup `
            -ArgumentList '-quiet -norestart ACCEPT_EULA=1'
        if ($proc.ExitCode -ne 0) {
            throw "PBIDesktopSetup_x64.exe failed with exit code $($proc.ExitCode)"
        }
    }

    Write-Host 'Done.'
    exit 0
}
catch {
    Write-Error "PowerBI64 install failed: $_"
    exit 1
}
