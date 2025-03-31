<#PSScriptInfo

.VERSION 3.0.0

.GUID 05c58731-6a7a-4a18-9903-03530b7ec896

.AUTHOR asherto

.COMPANYNAME asheroto

.TAGS PowerShell Windows root certificates certificate update updater lists list certutil certutil.exe sst cab microsoft windows

.PROJECTURI https://github.com/asheroto/Root-Certificate-Updater

.RELEASENOTES
[Version 1.11.0] - Initial PowerShell Gallery release.
[Version 1.11.1] - Fix URL to GUI counterpart.
[Version 2.0.0] - Refactored & signed code.
[Version 3.0.0] - Switched from Certificate Trusts Lists to Certificates due to revocation issues.

#>

<#
.SYNOPSIS
    Force update the root certificate lists on your computer.
.DESCRIPTION
	Downloads the latest root certificate lists from Microsoft and installs them on your computer.

	Optionally you can specify the -Force parameter to skip the 10 second wait before continuing execution.

	This program updates the trusted and disallowed root certificates on your system by downloading and installing the latest versions directly from Microsoft. These certificates are used by Windows to determine whether to trust or block websites, software, and other secure communications. By installing them manually, this tool ensures your system has the latest root certificates without relying on Windows Update.

	Its GUI counterpart is available at https://github.com/asheroto/Root-Certificate-Updater
.EXAMPLE
	Update root certificate lists normally: UpdateRootCertificates.ps1
.EXAMPLE
	Update root certificate lists without waiting 10 seconds to continue execution: UpdateRootCertificates.ps1 -Force
.NOTES
    Version      : 3.0.0
    Created by   : asheroto
.LINK
    Project Site: https://github.com/asheroto/Root-Certificate-Updater
#>

# Ensure script running as Administrator
#Requires -RunAsAdministrator

# Skip 10 second wait before continuing execution
[CmdletBinding()]
param ([Parameter(Mandatory = $false)][switch]$Force)

function Fail {
	param([string]$Message)
	Write-Warning $Message
	Write-Output ""
	Write-Warning "The process failed. Make sure you're connected to the internet, running PowerShell as Administrator, and have the latest version installed."
	Write-Output ""
	Write-Output "For help, visit: https://github.com/asheroto/Root-Certificate-Updater under the 'Issues' tab."
	Pop-Location
	Break
}

Clear-Host
Write-Output ""

Write-Output "Root Certificate Updater"
Write-Output ""
Write-Output "This script downloads and installs updated root and disallowed certificates from Microsoft. These certificates are used by Windows to determine whether to trust or reject connections, software, and other services."
Write-Output ""
Write-Output "Reference: https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/faqs-root-certificates"
Write-Output ""
Write-Output ("-" * 50)

if (-not $Force) {
	Write-Output ""
	Write-Output "Updated root and disallowed certificates will be installed in 10 seconds. Press CTRL+C to cancel."
	Write-Output ""
	Start-Sleep -Seconds 10
	Write-Output ("-" * 50)
}

Write-Output "Checking if Windows Update is allowed to install trusted root certificates..."
Write-Output ""
$ShowAUMessage = $true
$val = Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\SystemCertificates\AuthRoot' -Name 'DisableRootAutoUpdate' -ErrorAction Ignore
if ($val.DisableRootAutoUpdate -eq 1) {
	Write-Warning "Your system is configured to block automatic updates of trusted root certificates."
	Write-Output ""
	Write-Output "    To change this setting, check the registry value:"
	Write-Output "        HKLM\Software\Policies\Microsoft\SystemCertificates\AuthRoot\DisableRootAutoUpdate"
	$ShowAUMessage = $false
}
if ($ShowAUMessage) {
	Write-Output "    Trusted root certificates are allowed to be updated automatically by Windows Update."
}
Write-Output ""

Write-Output "Checking if Windows Update is allowed to install disallowed certificates..."
Write-Output ""
$ShowAUMessageD = $true
$val = Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\SystemCertificates\AuthRoot' -Name 'EnableDisallowedCertAutoUpdate' -ErrorAction Ignore
if ($val.EnableDisallowedCertAutoUpdate -eq 0) {
	Write-Warning "Your system is configured to block automatic updates of disallowed certificates."
	Write-Output ""
	Write-Output "    To change this setting, check the registry value:"
	Write-Output "        HKLM\Software\Policies\Microsoft\SystemCertificates\AuthRoot\EnableDisallowedCertAutoUpdate"
	$ShowAUMessageD = $false
}
if ($ShowAUMessageD) {
	Write-Output "    Disallowed certificates are allowed to be updated automatically by Windows Update."
}
Write-Output ("-" * 50)
Write-Output ""

# Store current location
Push-Location $pwd

# Go to temp path
$TempDir = [System.IO.Path]::GetTempPath()
Set-Location $TempDir

# Download and install .sst certificate lists
$ProgressPreference = "SilentlyContinue"
Write-Output "Downloading updated root and disallowed certificate files from Microsoft..."
Write-Output ""

$baseUrl = "http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/"
$trustedFiles = @("authroots.sst", "updroots.sst", "roots.sst")
$disallowedFile = "disallowedcert.sst"

# Download all files
foreach ($file in $trustedFiles + $disallowedFile) {
	Invoke-WebRequest -Uri ($baseUrl + $file) -OutFile $file
	if (-not (Test-Path $file)) {
		Fail -Message "$file was not downloaded. Check your Internet connection and try again."
	}
}

# Install trusted certs
foreach ($file in $trustedFiles) {
	if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"]) {
		certutil -f -addstore root $file
	} else {
		certutil -f -addstore root $file > $null 2>&1
	}
	Write-Output "$file installed to Root store."
}

# Install disallowed certs
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"]) {
	certutil -f -addstore disallowed $disallowedFile
} else {
	certutil -f -addstore disallowed $disallowedFile > $null 2>&1
}
Write-Output "$disallowedFile installed to Disallowed store."

# Cleanup
Remove-Item authroots.sst, updroots.sst, roots.sst, disallowedcert.sst

Write-Output ""
Write-Output ("-" * 50)
Write-Output "Certificates were successfully downloaded and installed."
Write-Output "Please restart the computer for changes to fully take effect."
Write-Output ("-" * 50)
Write-Output ""

# Restore original location
Pop-Location