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