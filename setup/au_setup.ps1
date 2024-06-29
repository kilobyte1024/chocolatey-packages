# WMF 3/4 only
if ($PSVersionTable.PSVersion -lt $(New-Object System.Version("5.0.0.0"))) {
  Write-Output Unsupported shell.
  exit 1
}

$refreshenv = Get-Command refreshenv -ea SilentlyContinue
if ($null -ne $refreshenv -and $refreshenv.CommandType -ne 'Application') {
  refreshenv # You need the Chocolatey profile installed for this to work properly (Choco v0.9.10.0+).
} else {
  Write-Warning "We detected that you do not have the Chocolatey PowerShell profile installed, which is necessary for 'refreshenv' to work in PowerShell."
}

Install-PackageProvider -Name NuGet -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module Chocolatey-AU -Scope AllUsers
Get-Module Chocolatey-AU -ListAvailable | select Name, Version
