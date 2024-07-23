$ErrorActionPreference  = 'Stop'

$packageArgs = @{
  packageName       = 'discord.install'
  fileType          = 'exe'
  url               = 'https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9053/DiscordSetup.exe'
  url64bit          = 'https://dl.discordapp.net/distro/app/stable/win/x64/1.0.9154/DiscordSetup.exe'

  softwareName      = 'discord*'

  checksum          = '5E5E327A2E995639BC9C6E1C00CAF35CFD91C2E34A8432702D9D622BA3ECA6F1'
  checksumType      = 'sha256'
  checksum64        = '1EDB5F8AFEE1A82927EA41A498719E8415F7F1CBF77942B20224CC28A51A9BE0'
  checksumType64    = 'sha256'

  silentArgs        = "-s"
  validExitCodes    = @(0)
}

$pathsToSearch = @()
if (Test-Path (Join-Path $Env:LOCALAPPDATA -ChildPath 'Discord')) {
  $pathsToSearch = Join-Path $Env:LOCALAPPDATA -ChildPath 'Discord\*\Discord.exe' -Resolve
}
$pathsToSearch += Join-Path $Env:ProgramFiles -ChildPath 'Discord\Discord.exe'
if ($Env:ProgramFilesX86) {
  $pathsToSearch += Join-Path $Env:ProgramFilesX86 -ChildPath 'Discord\Discord.exe'
}
$DiscordPresent = $false

# ex: C:\Users\foobar\AppData\Local\Discord\app-1.0.9153\Discord.exe
# Iterate through the paths and check if Discord.exe exists
$versions = @()
foreach ($path in $pathsToSearch) {
  if (Test-Path $path) {
    # Track each version # found
    $version = (Get-ItemProperty -Path $path -ErrorAction:SilentlyContinue).VersionInfo.ProductVersion
    if ($version) {
        $versions += ([Version]$version)
    }
  }
}

# Sort the versions in descending order (highest to lowest)
$versions = $versions | Sort-Object -Descending
Write-Host "Versions found: $versions"

# if Discord is present
if ($null -ne $versions -and $versions.Count -gt 0) {
  $InstalledVersion = $versions[0]
  $DiscordOutdated = [Version]$($Env:ChocolateyPackageVersion) -gt [Version]$InstalledVersion
  $DiscordPresent = $true
  Write-Host "Highest version found: $InstalledVersion"
} else {
  $DiscordPresent = $false
  Write-Host "No prior Discord installs found."
}

# Only Attempt an install if the existing version is older than the package version, or if forced
if (-not $DiscordPresent -or ($DiscordPresent -and $DiscordOutdated) -or $Env:ChocolateyForce)
{
  # stop the existing Discord process, if any
  Write-Host "Attempting to stop running Discord process (if any)..."
  Get-Process 'discord' -ErrorAction SilentlyContinue | Stop-Process -Force
  Write-Host "Installing package"
  Install-ChocolateyPackage @packageArgs
}
