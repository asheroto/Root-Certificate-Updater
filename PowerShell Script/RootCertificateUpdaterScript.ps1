# Created by asher.tools - https://asher.tools
# Code inspired by Alex - https://disq.us/p/2k43o76
#
# If you run this script and see an error about scripts being disabled,
# look up "Set-ExecutionPolicy" and set accordingly, then run this script again

# Ensure script running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Write-Warning "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
	Break
}

# Remember current directory
Push-Location $pwd

# Go to temporary directory
$TempDir = [System.IO.Path]::GetTempPath()
Set-Location $TempDir

# Download certificates
certutil -urlcache -f http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/authrootstl.cab authrootstl.cab
certutil -urlcache -f http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/disallowedcertstl.cab disallowedcertstl.cab

# Extract certificates from cab files
expand authrootstl.cab -R .\
expand disallowedcertstl.cab -R .\

# Add stl (certificate) files
certutil -addstore -f root authroot.stl
certutil -addstore -f disallowed disallowedcert.stl

# Wait a second
Start-Sleep -Seconds 1

# Delete temp files
Remove-Item authrootstl.cab, disallowedcertstl.cab
Remove-Item authroot.stl, disallowedcert.stl

# Message to user
Write-Output ""
Write-Output "-----------------------"
Write-Output "The root certificates were successfully downloaded and installed."
Write-Output "You need to restart the computer for changes to take effect."
Write-Output "-----------------------"
Write-Output ""

# Return to stored directory
Pop-Location

# Timeout for 3 seconds
Start-Sleep -Seconds 3