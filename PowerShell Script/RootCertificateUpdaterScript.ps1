# Created by asher.tools - https://asher.tools
# Code inspired by Alex - https://disq.us/p/2k43o76
#
# If you run this script and see an error about scripts being disabled,
# look up "Set-ExecutionPolicy" and set accordingly, then run this script again

# Ensure script running as Administrator
#Requires -RunAsAdministrator

# Space
Clear-Host
Write-Output "";

# Info
Write-Output "Root Certificate Updater";
Write-Output "Created by asher.tools - https://asher.tools";
Write-Output ""
Write-Output "This program updates the Certificate Trust Lists on your computer. Root certificate lists have the hashes of the certificates and don't contain the 'actual' certificates themselves, HOWEVER, this is because when a Windows machine encounters a new certificate that is on the trust list that it hasn't seen before, it will automatically download the needed certificate behind-the-scenes (on demand). The reason we use Certificate Trust Lists instead of the 'actual' certificates is because Windows Update is required to generate the certificates using certutil. If Windows Update is enabled and in use, that means your root certificates would already be up-to-date as it handles root certificate updates automatically. Using this method, we're able to achieve our goal of having the latest root certificates without relying on Windows Update."
Write-Output ""
Write-Output "Reference: https://learn.microsoft.com/en-us/previous-versions//cc751157(v=technet.10)";
Write-Output ""
Write-Output $("-" * 50)

# Check if Windows Update is allowed to update trusted root certificates
Write-Output "Checking if Windows Update is allowed to update 'trusted' root certificates...";Write-Output "";
$ShowAUMessage = $true;
If ($val = Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\SystemCertificates\AuthRoot' -Name DisableRootAutoUpdate -ErrorAction Ignore) {
	If ($val.DisableRootAutoUpdate -eq 1) {
		Write-Warning "Your settings do NOT allow 'trusted' root certificate updates through Windows Update.";Write-Output "";
		Write-Output "To change, check the 'DisableRootAutoUpdate' value in the registry key";
		Write-Output "	'HKLM\Software\Policies\Microsoft\SystemCertificates\AuthRoot'";
		$ShowAUMessage = $false;
	}
}
If($ShowAUMessage) {
	Write-Output "Windows is configured automatically update 'trusted' root certificates through Windows Update";
}
Write-Output $("-" * 50);
Write-Output "";

# Check if Windows Update is allowed to download untrusted root certificates
$ShowAUMessageD = $true;
If ($val = Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\SystemCertificates\AuthRoot' -Name EnableDisallowedCertAutoUpdate -ErrorAction Ignore) {
	If ($val.EnableDisallowedCertAutoUpdate -eq 1) {
		Write-Warning "Your settings do NOT allow 'untrusted' root certificate updates through Windows Update.";Write-Output "";
		Write-Output "To change, check the 'EnableDisallowedCertAutoUpdate' value in the registry key";
		Write-Output "	'HKLM\Software\Policies\Microsoft\SystemCertificates\AuthRoot'";
		$ShowAUMessageD = $false;
	}
}
If($ShowAUMessageD) {
	Write-Output "Windows is configured automatically update 'untrusted' root certificates through Windows Update";
}
Write-Output $("-" * 50);
Write-Output "";

# Remember current directory
Push-Location $pwd

# Go to temporary directory
$TempDir = [System.IO.Path]::GetTempPath()
Set-Location $TempDir

# Download the latest root certificates
$ProgressPreference = "SilentlyContinue"
Write-Output "Downloading the latest Certificate Trust Lists files from Microsofft...";Write-Output "";
Invoke-WebRequest -Uri "http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/authrootstl.cab" -OutFile "authrootstl.cab"
Invoke-WebRequest -Uri "http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/disallowedcertstl.cab" -OutFile "disallowedcertstl.cab"

# Confirm the files downloaded
if (-NOT (Test-Path authrootstl.cab)) {
	Write-Warning "authrootstl.cab not found. Check your Internet connection and try again."
	Pop-Location
	Break
}
if (-NOT (Test-Path disallowedcertstl.cab)) {
	Write-Warning "disallowedcertstl.cab not found. Check your Internet connection and try again."
	Pop-Location
	Break
}

# Extract certificates from cab files
expand authrootstl.cab -R .\
expand disallowedcertstl.cab -R .\

# Add stl (certificate) files
certutil -f -addstore root authroot.stl
certutil -f -addstore disallowed disallowedcert.stl

# Wait a second
Start-Sleep -Seconds 1

# Delete temp files
Remove-Item authrootstl.cab, disallowedcertstl.cab
Remove-Item authroot.stl, disallowedcert.stl

# Message to user
Write-Output ""
Write-Output $("-" * 50)
Write-Output "The root certificates lists were successfully downloaded and installed. When your computer sees a root certificate it hasn't encountered before, it will automatically download it."
Write-Output ""
Write-Output "Please restart the computer for changes to take effect."
Write-Output $("-" * 50)
Write-Output ""

# Return to stored directory
Pop-Location
# SIG # Begin signature block
# MIIpygYJKoZIhvcNAQcCoIIpuzCCKbcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBNWj5RHPe7Nw3q
# 73dgy0aLrwzeN8H54qmBGWpEIp7Wa6CCDrkwggawMIIEmKADAgECAhAIrUCyYNKc
# TJ9ezam9k67ZMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0z
# NjA0MjgyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDVtC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0
# JAfhS0/TeEP0F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJr
# Q5qZ8sU7H/Lvy0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhF
# LqGfLOEYwhrMxe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+F
# LEikVoQ11vkunKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh
# 3K3kGKDYwSNHR7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJ
# wZPt4bRc4G/rJvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQay
# g9Rc9hUZTO1i4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbI
# YViY9XwCFjyDKK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchAp
# QfDVxW0mdmgRQRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRro
# OBl8ZhzNeDhFMJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IB
# WTCCAVUwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+
# YXsIiGX0TkIwHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAC
# hjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAED
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql
# +Eg08yy25nRm95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFF
# UP2cvbaF4HZ+N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1h
# mYFW9snjdufE5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3Ryw
# YFzzDaju4ImhvTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5Ubdld
# AhQfQDN8A+KVssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw
# 8MzK7/0pNVwfiThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnP
# LqR0kq3bPKSchh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatE
# QOON8BUozu3xGFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bn
# KD+sEq6lLyJsQfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQji
# WQ1tygVQK+pKHJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbq
# yK+p/pQd52MbOoZWeE4wgggBMIIF6aADAgECAhAOyLAmjUpdRlQheQrwADJFMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjIwNDAxMDAwMDAwWhcNMjMwNDAx
# MjM1OTU5WjCB0zETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhPa2xhaG9tYTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEzARBgNV
# BAUTCjE5MTMwMjk2MDExCzAJBgNVBAYTAlVTMREwDwYDVQQIEwhPa2xhaG9tYTER
# MA8GA1UEBxMITXVza29nZWUxHDAaBgNVBAoTE0FzaGVyIFNvbHV0aW9ucyBJbmMx
# HDAaBgNVBAMTE0FzaGVyIFNvbHV0aW9ucyBJbmMwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCwsC6ZPJjALlD34NKQyBQp7LMwO61CnMijdMX5VdjqfbII
# 3bTcVIxd9c2VXA4CNHOySle9mwrUKg0/fuSMCL6v+YT+nlykdiGF+1JzF/xztPxi
# UYh/nosuzuJli1cKSqLklo1aJBSbaraI2d2uuEhuZs1bdtNEiDAqB9uzLM1sjdA9
# xMcGqa0a0fWHkiMTgcoTOXttegnjRaOfLjoOHMG885zCbivqvUi1PDw/denxiY8J
# USIlXrfRXG63+HOzp4CyX4BTOdhhljj9KB5WVo8671gBdFFjxG9sjlDpBqT11etn
# ZUS3WUNOx3RnAmUQeriDSlChZuDr4oGS5C2Czwv5tKp/lWsbmBzIlBek0IuxKv+B
# Ve5dIM8lx5o8FV+mHyt9OWPqh1G4I03vS4KQTKs79ck7msPUcWICBb9WUKSFiKbL
# 991jbjY8cviKvI7keQiY+kOP3kH83H8vNSe6cFoFEBFDlq3giO1BYV/36bSsM9xx
# ZgBXQqfMqjqX/HsCRMSRb6aS/GaETq0s9/5ExMJEoLPTN/xi4h+ErLTooX6DgY2Y
# 4Lg5zWeSX3rC9b2/h5SifXxhKDxL8B4V6Pba0mOhc36TcTmPIbz0rBn097i8kuCG
# h11jpqCgfi2jtyyEbsOvEcpnQAwb/SiWbznD0IpNwsnYk5t1hBYx4TTxU8FrNQID
# AQABo4ICODCCAjQwHwYDVR0jBBgwFoAUaDfg67Y7+F8Rhvv+YXsIiGX0TkIwHQYD
# VR0OBBYEFNK8fnBc0Eyw1svglEaxakfmNIEzMDEGA1UdEQQqMCigJgYIKwYBBQUH
# CAOgGjAYDBZVUy1PS0xBSE9NQS0xOTEzMDI5NjAxMA4GA1UdDwEB/wQEAwIHgDAT
# BgNVHSUEDDAKBggrBgEFBQcDAzCBtQYDVR0fBIGtMIGqMFOgUaBPhk1odHRwOi8v
# Y3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JT
# QTQwOTZTSEEzODQyMDIxQ0ExLmNybDBToFGgT4ZNaHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0
# MjAyMUNBMS5jcmwwPQYDVR0gBDYwNDAyBgVngQwBAzApMCcGCCsGAQUFBwIBFhto
# dHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwgZQGCCsGAQUFBwEBBIGHMIGEMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wXAYIKwYBBQUHMAKG
# UGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENv
# ZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3J0MAwGA1UdEwEB/wQCMAAw
# DQYJKoZIhvcNAQELBQADggIBABH5uRf88l9+NJ1427Htk3pDHtE1xpJjWI2GNx6H
# ML7PkUqt8VTYOBZcyN/GpQKbp4aA+YNvRK4r/YN3LelR5j+OItSiNcY9f/x0ODfZ
# 90pBvuo+1HCBaZAHhnuiMQFH80ej/vtQ6YtAhphOGjKWEeStCtFp5WD5NNZICBYF
# /omOktMibMWpbR+ya5bT1l/VmnBrMawljkZqy4aKWT4quKb5p1mHcVD2SJxqEKrt
# Ql8iHFR0j96vNnuhWRpYGs38AAx3vWrX/6sGTLXdyrjsHVVYOcRD/DuH2kGXFzmL
# T7/1RGEZJDIQkWDgDJEmjIC98O9uO+gFTwkqkyen3gHj7DzMMtHTnkVe8Efu7Vtf
# qE4EkcPk3eXIL/tEmtr3sXqBKLoNm+c1OUn9PdzZwNFqBgPHZvLKfBtOI1Q/2C88
# fTOEFofJIC2s95MAGMgzHbJOPSWhNRDNkIJbFaGeCxlddb7DoWtKoCZhFtEKtrSF
# h7kzXSvqQqJTsE8z9pB/pRyDNzSYMqDHifZy6rkMkqd7Nv3btUzlyzFxrok3+CDs
# XfwXbO2PJe6HUL2Cvq5lw+1/dsedOoNbdvmX0e84W8tFbJJPs3as1u6OdtRs7tmB
# A/VJxtkZp5vMH4Erdw3ZagCHUGRMX+a5rNzMElHFSkoR5cOt7sKXBzyKx/tI0XgV
# sCHhMYIaZzCCGmMCAQEwfTBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNl
# cnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgQ29kZSBTaWdu
# aW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0ExAhAOyLAmjUpdRlQheQrwADJFMA0G
# CWCGSAFlAwQCAQUAoHwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwG
# CisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZI
# hvcNAQkEMSIEIHH8OpTFL6gFDmKhym4+fKzc6EHGOqW787rHqrdID8oHMA0GCSqG
# SIb3DQEBAQUABIICADMQ52yz+OdFWLapovSja125aDwtY9BM5TzFebBwS+hpDZHJ
# Y8VAhqwqIkMFdyoc+/A6emubfeZGQ/gYLuGUo4ACrmBBzqxFtU5FwEWZSpNJ8XjN
# UzxStFnK8DpuK/dFMOo3O1kpc1DE+JDDAUPgaDBzBUfxnAOKFcn/kv+GaeLCDqwX
# fBBvunBgrRAJWtIK7k87K56BLOr2r1RFnLHvZohwGTcdxQCw0ydCpv08oqIheZK2
# 8mnNukwvUpNz9ZOc0eCZfcGFTRL/fXQjDjVN4IhZNii/bRTQSh0ZzIC+XADFobU5
# wYHS87tJT1ZQKTtjEb58abBSfruif4Tq+TTyrLBDEWuHwUURu/848so9wIlo/qJa
# eRLZ5YjDcdVX6LKeoxNVqPUCetQ1YwcPIZNrO7sVBlqaCDNQJ2/DTtZJ2wXcTXjI
# B33dYzzhEOU5Qe3gCAJw7irxyGoYUzBy7qwPH9dEB2zT7bm6iD9hyNcixxCEWOrM
# qavvyyy1AfkSUHp49FFtaofJjtTBvGHXt8OaOQFCc1WnKCJvvlXYiPn0QhfQV18w
# +kDmtyXJflD1gzaazNSxx/LQj2TZQqGH5TuE0UTyG3OLi812PnMXf0DBpgZTnmiL
# 530AaY0QOb7n9F+RtSAPb+d4biYew1S87TLJjkLT+FM2E7vBhbU0jSDTgRDAoYIX
# PTCCFzkGCisGAQQBgjcDAwExghcpMIIXJQYJKoZIhvcNAQcCoIIXFjCCFxICAQMx
# DzANBglghkgBZQMEAgEFADB3BgsqhkiG9w0BCRABBKBoBGYwZAIBAQYJYIZIAYb9
# bAcBMDEwDQYJYIZIAWUDBAIBBQAEIJLJCIitRBOI/cx8uT/Lvcv+WmPK1HSvh6wM
# yJG2NetHAhB8JB0HcTj7q+7eedoP2hWgGA8yMDIyMTAwNDE2MDcwMVqgghMHMIIG
# wDCCBKigAwIBAgIQDE1pckuU+jwqSj0pB4A9WjANBgkqhkiG9w0BAQsFADBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# MB4XDTIyMDkyMTAwMDAwMFoXDTMzMTEyMTIzNTk1OVowRjELMAkGA1UEBhMCVVMx
# ETAPBgNVBAoTCERpZ2lDZXJ0MSQwIgYDVQQDExtEaWdpQ2VydCBUaW1lc3RhbXAg
# MjAyMiAtIDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDP7KUmOsap
# 8mu7jcENmtuh6BSFdDMaJqzQHFUeHjZtvJJVDGH0nQl3PRWWCC9rZKT9BoMW15GS
# OBwxApb7crGXOlWvM+xhiummKNuQY1y9iVPgOi2Mh0KuJqTku3h4uXoW4VbGwLpk
# U7sqFudQSLuIaQyIxvG+4C99O7HKU41Agx7ny3JJKB5MgB6FVueF7fJhvKo6B332
# q27lZt3iXPUv7Y3UTZWEaOOAy2p50dIQkUYp6z4m8rSMzUy5Zsi7qlA4DeWMlF0Z
# Wr/1e0BubxaompyVR4aFeT4MXmaMGgokvpyq0py2909ueMQoP6McD1AGN7oI2TWm
# tR7aeFgdOej4TJEQln5N4d3CraV++C0bH+wrRhijGfY59/XBT3EuiQMRoku7mL/6
# T+R7Nu8GRORV/zbq5Xwx5/PCUsTmFntafqUlc9vAapkhLWPlWfVNL5AfJ7fSqxTl
# OGaHUQhr+1NDOdBk+lbP4PQK5hRtZHi7mP2Uw3Mh8y/CLiDXgazT8QfU4b3ZXUtu
# MZQpi+ZBpGWUwFjl5S4pkKa3YWT62SBsGFFguqaBDwklU/G/O+mrBw5qBzliGcnW
# hX8T2Y15z2LF7OF7ucxnEweawXjtxojIsG4yeccLWYONxu71LHx7jstkifGxxLjn
# U15fVdJ9GSlZA076XepFcxyEftfO4tQ6dwIDAQABo4IBizCCAYcwDgYDVR0PAQH/
# BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYD
# VR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1N
# hS9zKXaaL3WMaiCPnshvMB0GA1UdDgQWBBRiit7QYfyPMRTtlwvNPSqUFN9SnDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQBggr
# BgEFBQcBAQSBgzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQu
# Y29tMFgGCCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGln
# aUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0MA0G
# CSqGSIb3DQEBCwUAA4ICAQBVqioa80bzeFc3MPx140/WhSPx/PmVOZsl5vdyipjD
# d9Rk/BX7NsJJUSx4iGNVCUY5APxp1MqbKfujP8DJAJsTHbCYidx48s18hc1Tna9i
# 4mFmoxQqRYdKmEIrUPwbtZ4IMAn65C3XCYl5+QnmiM59G7hqopvBU2AJ6KO4ndet
# Hxy47JhB8PYOgPvk/9+dEKfrALpfSo8aOlK06r8JSRU1NlmaD1TSsht/fl4JrXZU
# inRtytIFZyt26/+YsiaVOBmIRBTlClmia+ciPkQh0j8cwJvtfEiy2JIMkU88ZpSv
# XQJT657inuTTH4YBZJwAwuladHUNPeF5iL8cAZfJGSOA1zZaX5YWsWMMxkZAO85d
# NdRZPkOaGK7DycvD+5sTX2q1x+DzBcNZ3ydiK95ByVO5/zQQZ/YmMph7/lxClIGU
# gp2sCovGSxVK05iQRWAzgOAj3vgDpPZFR+XOuANCR+hBNnF3rf2i6Jd0Ti7aHh2M
# WsgemtXC8MYiqE+bvdgcmlHEL5r2X6cnl7qWLoVXwGDneFZ/au/ClZpLEQLIgpzJ
# GgV8unG1TnqZbPTontRamMifv427GFxD9dAq6OJi7ngE273R+1sKqHB+8JeEeOMI
# A11HLGOoJTiXAdI/Otrl5fbmm9x+LMz/F0xNAKLY1gEOuIvu5uByVYksJxlh9ncB
# jDCCBq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAw
# YjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290
# IEc0MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMC
# VVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBU
# cnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh
# 1tKD0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+Feo
# An39Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1
# decfBmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxnd
# X7RUCyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6
# Th+xtVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPj
# Q2OAe3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlREr
# WHRAKKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JM
# q++bPf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh
# 3pP+OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8j
# u2TjY+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnS
# DmuZDNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1Ud
# DgQWBBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzf
# Lmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgw
# dwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2Vy
# dC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6
# Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAG
# A1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOC
# AgEAfVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp
# /GnBzx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40B
# IiXOlWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2d
# fNBwCnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibB
# t94q6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7
# T6NJuXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZA
# myEhQNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdB
# eHo46Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnK
# cPA3v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/
# pNHzV9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yY
# lvZVVCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggWNMIIEdaADAgEC
# AhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVT
# MRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5j
# b20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4
# MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQAD
# ggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVir
# dprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcW
# WVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5O
# yJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7K
# e13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1
# gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn
# 3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7n
# DmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIR
# t7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEd
# slQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j
# 7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMB
# AAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzf
# Lmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNV
# HQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8v
# b2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4w
# PDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQAD
# ggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3
# bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP
# 0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZ
# NUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPL
# ILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9
# W9FcrBjDTZ9ztwGpn1eqXijiuZQxggN2MIIDcgIBATB3MGMxCzAJBgNVBAYTAlVT
# MRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1
# c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxNaXJLlPo8
# Kko9KQeAPVowDQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3
# DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMjEwMDQxNjA3MDFaMCsGCyqGSIb3DQEJ
# EAIMMRwwGjAYMBYEFPOHIk2GM4KSNamUvL2Plun+HHxzMC8GCSqGSIb3DQEJBDEi
# BCDzHEaPHos50+XWaHiwGxFkTuwy/eEcQBh0X/oKXMN2HDA3BgsqhkiG9w0BCRAC
# LzEoMCYwJDAiBCDH9OG+MiiJIKviJjq+GsT8T+Z4HC1k0EyAdVegI7W2+jANBgkq
# hkiG9w0BAQEFAASCAgAZi1ya76EL7xUx9UxOOz5tHUfQXQ2psgxoF8kcVsjEp9WK
# wSA6Cpny0C9KjatigeVhmlS88zfTvlVlEEEUTD3CKbsZ9Mo85nKiacpZWHlpm7Mc
# z4Ufzi8WkL+Vra/X0kf5oMzJz4nx3dnSNZhqPXzgpG0tU6CH+p8CNS1f90+Ok9UJ
# LtIaaVPaiaEPGZp3YMT/Ivh5cCFjkDAuEV5Tx0MvQ5f60xvlCNIOQ47lRdNrRpxE
# vsa8+SE8xOfQ/mhtnoi7clMY2xbAfi/vqCO5p8MzWBjVeFpD4yjUz5aEiC7P5Wxp
# YCL4gpsB6eGtPCi/42VG6gYFsJlAQOEZDY3VC7OcJYo7MZZGfq/JpSaRHjvOGYuF
# tikTL1SisIxS32y1MIvewo+Co9jHjN/kVyAkeCG0XfopcEWjvaRWFoUSsAtVwPlX
# nETXXyxoqpQIR2LqRPz8tP278T1SzSWcEsf4L292vfNZHrX1jFWjyX7Hlajc4zIX
# gbmfOpozydJFv+viT0IfLEugSKTaOdqADKLb5p43T08h2nTE5Lvt1d6PtifUx+3G
# dBLZfvQ6grckYxjwDeADhEc08OnaxFEQjTgHx0GHeFOnfTTPlosjgxpwxe/+M7zb
# TnIXe9tcdfTE3e52TD4C9OiyuvBKQ7AaLJMHDQeT/D8HxMsh1JRCHEb4cNWcGQ==
# SIG # End signature block
