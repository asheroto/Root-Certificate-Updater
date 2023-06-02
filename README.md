# Root Certificate Updater
Update root certificates (and disallowed certificates) on Windows.

This repo contains **two options** to update root certificates. **Each option performs the same procedure.** 

If you're not sure which option to choose, use the GUI (the first option) as it's the easiest.

**No changes are made to any settings**, this **only** updates the root certificates. Windows Update is NOT required for this to work.

## **Option 1:** GUI
GUI application for updating root certificates. One click, done.

### Screenshot
![RootCertificateUpdater.exe](https://asher.tools/img/root_certificate_updater.png)

## **Option 2:** PowerShell Script
Update root certificates using a PowerShell script.

### Usage
|Command|Description|
|--|--|
|`.\UpdateRootCertificates.ps1`|Normal run|
|`.\UpdateRootCertificates.ps1 -Force`|Skip the 10 second wait before continuing execution|

### Installation
You can either download and run the `UpdateRootCertificates.ps1` script from this repo, or install from PowerShell Gallery by typing this in PowerShell:

```powershell
Install-Script UpdateRootCertificates
```
### Screenshot
![UpdateRootCertificates.ps1](https://asher.tools/img/root_certificate_updater_script.png)

# Downloads

[Download the latest version](https://github.com/asheroto/Root-Certificate-Updater/releases/latest/download/Root_Certificate_Updater.zip) from the releases page or from [asher.tools](https://asher.tools).

Password to the zip file is `password`.

Password enabled due to false positive detections by AV.

# Other Notes

The CMD version has been replaced by the PowerShell script.