[![Release](https://img.shields.io/github/v/release/asheroto/Root-Certificate-Updater)](https://github.com/asheroto/Root-Certificate-Updater/releases)
[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/Root-Certificate-Updater)](https://github.com/asheroto/Root-Certificate-Updater/releases)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/Root-Certificate-Updater/total)](https://github.com/asheroto/Root-Certificate-Updater/releases)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto?frequency=one-time&sponsor=asheroto)
<a href="https://ko-fi.com/asheroto"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Ko-Fi Button" height="20px"></a>
<a href="https://www.buymeacoffee.com/asheroto"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=Root-Certificate-Updater&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff)" height="40px"></a>

# UpdateRootCertificates (Root Certificate Updater)

> [!NOTE]
> The EXE (GUI) version has been deprecated and replaced by the PowerShell script version, which is now the only actively supported method. The EXE remains available in the repository for historical reference but is no longer maintained. The repository `Root-Certificate-Updater` has been renamed to `UpdateRootCertificates` to match the name of the script.

Update root certificates (and disallowed certificates) on Windows.

This script downloads and installs the latest `.sst` files from Microsoft containing trusted and disallowed root certificates.

**No changes are made to any system settings**, and **Windows Update is NOT required** for this to work.

![screenshot](https://github.com/user-attachments/assets/7c7cdd5b-fe76-47e5-8895-33126dc33b3a)

## Running the script

You can either:

- Download the [latest code-signed release](https://github.com/asheroto/Root-Certificate-Updater/releases/latest/download/UpdateRootCertificates.ps1) of the script

**OR**

- Install it from PowerShell Gallery using:

```powershell

Install-Script UpdateRootCertificates -Force

```

Published here: [PowerShell Gallery – UpdateRootCertificates](https://www.powershellgallery.com/packages/UpdateRootCertificates)

---

## Usage

| Command                                  | Description                                                      |
| ---------------------------------------- | ---------------------------------------------------------------- |
| `UpdateRootCertificates`                 | Normal execution                                                 |
| `UpdateRootCertificates -Force`          | Skips the 10-second wait before running                          |
| `UpdateRootCertificates -Verbose`        | Shows detailed output during certificate installation            |
| `UpdateRootCertificates -CheckForUpdate` | Checks for the latest version of the script                      |
| `UpdateRootCertificates -UpdateSelf`     | Updates the script to the latest version from PowerShell Gallery |
| `UpdateRootCertificates -Version`        | Displays the current script version                              |
| `UpdateRootCertificates -Help`           | Displays full help documentation                                 |

---

## Other Notes

- The PowerShell version downloads `.sst` files directly (e.g., `authroots.sst`, `updroots.sst`, `roots.sst`, `disallowedcert.sst`) from Microsoft’s root certificate update service.
- Files are installed using `certutil`
- All `.sst` files are removed after installation unless the process fails.
- The CMD and EXE-based versions have been replaced entirely by this PowerShell-based solution.