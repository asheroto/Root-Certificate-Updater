[![Release](https://img.shields.io/github/v/release/asheroto/Root-Certificate-Updater)](https://github.com/asheroto/Root-Certificate-Updater/releases)
[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/Root-Certificate-Updater)](https://github.com/asheroto/Root-Certificate-Updater/releases)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/Root-Certificate-Updater/total)](https://github.com/asheroto/Root-Certificate-Updater/releases)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto?frequency=one-time&sponsor=asheroto)
<a href="https://ko-fi.com/asheroto"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Ko-Fi Button" height="20px"></a>
<a href="https://www.buymeacoffee.com/asheroto"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=Root-Certificate-Updater&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff)" height="40px"></a>

# Root Certificate Updater

Update root certificates (and disallowed certificates) on Windows.

This script downloads and installs the latest `.sst` files from Microsoft containing trusted and disallowed root certificates.

**No changes are made to any system settings**, and **Windows Update is NOT required** for this to work.

---

### ⚠️ Notice

The **EXE (GUI) version has been deprecated** and is no longer maintained.

Only the **PowerShell script version** is current and supported.

---

### Installation

You can either:

- Download the `.ps1` script directly from this repository

**OR**

- Install it from PowerShell Gallery using:

```powershell

Install-Script UpdateRootCertificates

```

Published here: [PowerShell Gallery – UpdateRootCertificates](https://www.powershellgallery.com/packages/UpdateRootCertificates)

> The code is signed. If you want to edit it, remove the `# SIG # Begin signature block` and everything below it.

---

### Usage

| Command                           | Description                                           |
| --------------------------------- | ----------------------------------------------------- |
| `UpdateRootCertificates`          | Normal execution                                      |
| `UpdateRootCertificates -Force`   | Skips the 10-second wait before running               |
| `UpdateRootCertificates -Verbose` | Shows detailed output during certificate installation |

---

### Screenshot

![UpdateRootCertificates Screenshot](https://github.com/user-attachments/assets/15a58740-79cb-488c-a78c-64a99e15104c)

---

### Other Notes

- The PowerShell version downloads `.sst` files directly (e.g., `authroots.sst`, `updroots.sst`, `roots.sst`, `disallowedcert.sst`) from Microsoft’s root certificate update service.
- Files are installed using `certutil`
- All `.sst` files are removed after installation unless the process fails.
- The CMD and EXE-based versions have been replaced entirely by this PowerShell-based solution.