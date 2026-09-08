#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Silently installs the SAP GUI (SAP Logon) frontend and deploys saplogon.ini to every local user.
.DESCRIPTION
    Downloads the frontend zip and ini once (skips steps already done), runs NwSapSetup.exe
    unattended, then copies saplogon.ini into each local user's SAP\Common folder.
.NOTES
    Fill in -SourceZip, -SourceIni and -PackageName for your environment before running.
    Exit code 0 = success, non-zero = failure, for RMM/Intune/SCCM detection.
#>
[CmdletBinding()]
param(
    [string]$SourceZip   = 'https://link',        # TODO: URL to the SAP GUI frontend zip
    [string]$SourceIni   = 'https://link',        # TODO: URL to your saplogon.ini
    [string]$PackageName = 'ENTER PACKAGE',       # TODO: package name for NwSapSetup /Package=
    [string]$InstallRoot = 'C:\TEMP\INSTALL'
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$zip         = Join-Path $InstallRoot 'SAPFrontend_7.40.zip'
$installPath = 'C:\Program Files (x86)\SAP\FrontEnd\SAPgui\saplogon.exe'
$ini         = Join-Path $InstallRoot 'saplogon.ini'
$userDir     = 'C:\Users\*\AppData\Roaming\SAP\Common'
$folder      = Join-Path $InstallRoot 'SAPFrontend_7.40'

try {
    if (Test-Path -Path $installPath -PathType Leaf) {
        Write-Host 'SAP GUI already installed - skipping download/install.'
    }
    else {
        if (Test-Path -Path $zip -PathType Leaf) {
            Write-Host 'Installer already downloaded.'
        }
        else {
            Write-Host "Creating $InstallRoot"
            New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null
            Write-Host 'Downloading SAP GUI frontend...'
            Start-BitsTransfer -Source $SourceZip -Destination $zip
        }

        if (Test-Path -Path $folder) {
            Write-Host 'Installer already expanded.'
        }
        else {
            Write-Host 'Expanding archive...'
            Expand-Archive -LiteralPath $zip -DestinationPath $InstallRoot -Force
        }

        Write-Host 'Running unattended install...'
        $proc = Start-Process -Wait -PassThru `
            -FilePath (Join-Path $folder 'Sources\Setup\NwSapSetup.exe') `
            -ArgumentList "/Silent /Package=`"$PackageName`""
        if ($proc.ExitCode -ne 0) {
            throw "NwSapSetup.exe failed with exit code $($proc.ExitCode)"
        }
    }

    Write-Host 'Downloading saplogon.ini...'
    Start-BitsTransfer -Source $SourceIni -Destination $ini

    Write-Host 'Deploying saplogon.ini to user profiles...'
    Get-ChildItem -Path $userDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item -Path $ini -Destination $_.FullName -Force
    }

    Write-Host 'Done.'
    exit 0
}
catch {
    Write-Error "Install-SAP failed: $_"
    exit 1
}
